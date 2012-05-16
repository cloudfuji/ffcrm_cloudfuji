class AddLeadScoringRules < ActiveRecord::Migration
  def up
   create_table :lead_scoring_rules do |t|
      t.string  :event
      t.string  :match
      t.integer :points, :default => 0
      t.boolean :once
      t.timestamps
    end

    create_table :lead_scoring_rule_counts do |t|
      t.integer :lead_id
      t.integer :lead_scoring_rule_id
      t.integer :count, :default => 0
    end

    add_column :leads, :score, :integer, :default => 0
  end

  def down
    drop_table :lead_scoring_rules
    drop_table :lead_scoring_rule_counts
    remove_column :leads, :score
  end
end
