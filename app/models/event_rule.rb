class EventRule < ActiveRecord::Base
  
  # event category validations
  validates_presence_of :event_category
  validates_presence_of :cloudfuji_event, :if => lambda { self.event_category == 'cloudfuji_event_received' }
  validates_presence_of :lead_attribute,  :if => lambda { self.event_category == 'lead_attribute_changed' }

  # action validations
  validates_presence_of :action
  validates_presence_of :action_tag,      :if => lambda { %w(add_tag remove_tag).include?(self.action) }
  validates_numericality_of :change_score_by, :only_integer => true, :if => lambda { self.action == 'change_lead_score' }

  validates_numericality_of :limit_per_lead,  :only_integer => true, :allow_blank => true

  has_many :lead_event_rule_counts
end
