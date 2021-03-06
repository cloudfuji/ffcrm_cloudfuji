class EventRule < ActiveRecord::Base

  # event category validations
  validates_presence_of :event_category
  validates_presence_of :lead_attribute,     :if => lambda { self.event_category  == 'lead_attribute_changed' }
  validates_presence_of :cloudfuji_event,    :if => lambda { self.event_category  == 'cloudfuji_event_received' }
  validates_presence_of :page_name, :app_id, :if => lambda { self.cloudfuji_event == 'page_loaded' }

  # action validations
  validates_presence_of :action
  validates_presence_of :tag, :if => lambda { %w(add_tag remove_tag).include?(self.action) }
  validates_presence_of :mailing_list, :mailing_list_group, :mailing_list_grouping, :if => lambda { self.action == "add_to_mailing_list_group" }

  validates_numericality_of :change_score_by, :only_integer => true, :if => lambda { self.action == 'change_lead_score' }

  validates_numericality_of :limit_per_lead,  :only_integer => true, :allow_blank => true

  has_many :lead_event_rule_counts

  def process(lead, params = {})
    # How many times this rule has been applied to a given Lead
    count = LeadEventRuleCount.find_by_lead_id_and_event_rule_id(lead, self) ||
            LeadEventRuleCount.new(:lead => lead, :event_rule => self)
    # Don't apply this rule more than limit_per_lead, if set
    unless limit_per_lead.present? && count.count > limit_per_lead
      # If :match is present, only apply the rule if data matches string
      if match.blank? || event_matches?(params)
        if (app_id.blank? && page_name.blank?) || page_and_app_matches?(params)
          # Run the action method if defined
          if respond_to?(action)
            send(action, lead, params)
            # Increment and save count of rule/lead applications
            count.count += 1
            count.save
          else
            raise "Do not know how to process '#{action}' action."
          end
        end
      end
    end
  end

  # Actions
  # -----------------------------------------------------------------
  def change_lead_score(lead, match_data)
    lead.without_versioning do
      lead.update_attribute :score, lead.score + change_score_by
    end
    # Add history event to lead, to record change of score
    lead.versions.create! :event => "Rule for #{human_event_label}: Score changed by #{change_score_by} points. (New total: #{lead.score})"
  end

  def send_notification(lead, match_data)
    if ::Cloudfuji::Platform.on_cloudfuji?
      # Fire a Cloudfuji event
      message = case event_category
      when 'cloudfuji_event_received'
        "Cloudfuji event was received - '#{cloudfuji_event}'"
      when 'lead_attribute_changed'
        "Lead \"#{lead.full_name}\" was updated - #{lead_attribute} was changed from '#{match_data['old_value']}' to '#{match_data['new_value']}'."
      end

      User.all.each do |user|
        user.notify(lead.full_name, message, "crm") if !user.ido_id.nil?
      end

    end
  end

  def add_tag(lead, match_data)
    lead.tag_list << tag
    save_lead_without_versioning_or_observers(lead)
    lead.versions.create! :event => "Rule for #{human_event_label}: Added tag '#{tag}'"
  end

  def remove_tag(lead, match_data)
    lead.tag_list -= [tag]
    save_lead_without_versioning_or_observers(lead)
    lead.versions.create! :event => "Rule for #{human_event_label}: Removed tag '#{tag}'"
  end

  def add_to_mailing_list_group(lead, match_data)
    # Send a Cloudfuji event which results in a call to the Mailchimp API,
    # and adds InterestGroup to lead.
    event = {
      :category => :mailing_list_group,
      :name     => :added,
      :data     => {
        :email                 => lead.email,
        :customer_ido_id       => lead.ido_id,
        :user_ido_id           => user_ido_id,
        :mailing_list          => mailing_list,
        :mailing_list_grouping => mailing_list_grouping,
        :mailing_list_group    => mailing_list_group
      }
    }

    puts "Publishing Cloudfuji Event: #{event.inspect}"
    ::Cloudfuji::Event.publish(event)
  end

  private

  def event_matches?(params)
    test_string = case_insensitive_matching ? match.downcase : match
    case event_category
    when 'cloudfuji_event_received'
      match_string = params['data'].inspect
      match_string.downcase! if case_insensitive_matching
      match_string.include?(test_string)
    when 'lead_attribute_changed'
      match_string = params['new_value'].to_s.dup
      match_string.downcase! if case_insensitive_matching
      match_string == test_string.to_s
    end
  end

  def page_and_app_matches?(params)
    (page_name.blank? || page_name == params["data"]["page"]) &&
    (app_id.blank? || app_id == params["app_id"])
  end

  def human_event_label
    case event_category
    when 'cloudfuji_event_received'; "Cloudfuji event - '#{cloudfuji_event}'"
    when 'lead_attribute_changed';   "Lead update - '#{lead_attribute}'"
    end
  end

  def save_lead_without_versioning_or_observers(lead)
    Lead.observers.disable :cloudfuji_lead_observer do
      lead.without_versioning do
        lead.save
      end
    end
  end
end
