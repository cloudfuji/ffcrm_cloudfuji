class RenameLeadScoringToEventRules < ActiveRecord::Migration
  def change
    rename_table  :lead_scoring_rules, :event_rules

    rename_table  :lead_scoring_rule_counts, :lead_event_rule_counts
    rename_column :lead_event_rule_counts, :lead_scoring_rule_id, :event_rule_id
  end
end
