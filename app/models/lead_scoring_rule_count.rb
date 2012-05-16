class LeadScoringRuleCount < ActiveRecord::Base
  belongs_to :lead
  belongs_to :lead_scoring_rule
end
