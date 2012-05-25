class LeadEventRuleCount < ActiveRecord::Base
  belongs_to :lead
  belongs_to :event_rule
end
