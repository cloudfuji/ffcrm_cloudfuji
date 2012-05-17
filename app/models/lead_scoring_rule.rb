class LeadScoringRule < ActiveRecord::Base
  validates_presence_of :event, :points
  validates_numericality_of :points, :only_integer => true

  has_many :lead_scoring_rule_counts
end