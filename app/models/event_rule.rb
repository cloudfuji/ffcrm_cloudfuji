class EventRule < ActiveRecord::Base
  
  # event category validations
  validates_presence_of :event_category
  validates_presence_of :cloudfuji_event, :if => lambda { self.event_category == 'cloudfuji_event_received' }
  validates_presence_of :lead_attribute,  :if => lambda { self.event_category == 'lead_attribute_changed' }

  # action validations
  validates_presence_of :action
  validates_presence_of :tag, :if => lambda { %w(add_tag remove_tag).include?(self.action) }
  validates_numericality_of :change_score_by, :only_integer => true, :if => lambda { self.action == 'change_lead_score' }

  validates_numericality_of :limit_per_lead,  :only_integer => true, :allow_blank => true

  has_many :lead_event_rule_counts
  
  def process(lead, match_data)
    # How many times this rule has been applied to a given Lead
    count = LeadEventRuleCount.find_by_lead_id_and_event_rule_id(lead, self) ||
            LeadEventRuleCount.new(:lead => lead, :event_rule => self)
    # Don't apply this rule more than limit_per_lead, if set
    unless limit_per_lead.present? && count.count > limit_per_lead
      # If :match is present, only apply the rule if data matches string
      if match.blank? || event_matches?(match_data)
        # Run the action method if defined
        if respond_to?(action)
          send(action, lead, match_data)
          # Increment and save count of rule/lead applications
          count.count += 1
          count.save
        else
          raise "Do not know how to process '#{action}' action."
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
        "Lead \"#{lead.full_name}\" was updated - #{lead_attribute} was changed from '#{match_data[0]}' to '#{match_data[1]}'."
      end
      
      event = {
        :category => :fat_free_crm,
        :name     => :notification,
        :data     => {
          :message  => message
        }
      }
      ::Cloudfuji::Event.publish(event)
    end
  end
  
  def add_tag(lead, match_data)
    lead.tag_list << tag
    lead.save
  end
  
  def remove_tag(lead, match_data)
    lead.tag_list -= [tag]
    lead.save
  end
  
  
  private
  
  def event_matches?(match_data)
    test_string = case_insensitive_matching ? match.downcase : match
    case event_category
    when 'cloudfuji_event_received'
      match_string = match_data.inspect
      match_string.downcase! if case_insensitive_matching
      match_string.include?(test_string) 
    when 'lead_attribute_changed'
      match_string = match_data[1].dup
      match_string.downcase! if case_insensitive_matching
      match_string == test_string
    end
  end
  
  def human_event_label
    case event_category
    when 'cloudfuji_event_received'; "Cloudfuji Event - '#{cloudfuji_event}'"
    when 'lead_attribute_changed';   "Lead Update - :#{lead_attribute}"
    end
  end
end
