class ExtendLeadScoringAsEventRules < ActiveRecord::Migration
  def up
    # Save current values of boolean :once column
    once_values = connection.select_all("SELECT id,once from lead_scoring_rules;")

    rename_table  :lead_scoring_rules, :event_rules

    rename_table  :lead_scoring_rule_counts, :lead_event_rule_counts
    rename_column :lead_event_rule_counts, :lead_scoring_rule_id, :event_rule_id

    add_column    :event_rules, :event_category, :string, :default => 'cloudfuji_event_received'

    # Columns for cloudfuji event matching
    rename_column :event_rules, :event, :cloudfuji_event
    rename_column :event_rules, :match, :cloudfuji_data_contains

    # Columns for lead column changes
    add_column    :event_rules, :lead_attribute, :string
    add_column    :event_rules, :lead_attribute_matches, :string

    # Columns for actions
    add_column    :event_rules, :action, :string, :default => 'change_lead_score'
    add_column    :event_rules, :action_tag, :string
    rename_column :event_rules, :points, :change_score_by

    remove_column :event_rules, :once
    add_column    :event_rules, :limit_per_lead, :integer
    add_column    :event_rules, :case_insensitive_matching, :boolean

    # Migrate :once values to :limit_times & :max_times
    ids = once_values.select{|v| v['once'] == 't' }.map {|v| v['id'] }
    if ids.any?
      connection.execute("UPDATE event_rules SET limit_times = 1, max_times = 1 WHERE id IN (#{ids.join(',')});")
    end

  end

  # Instead of meticulously mirroring the reverse of all these changes,
  # just drop the tables and re-create the tables from the previous migration.
  def down
    # Remove tables
    drop_table :event_rules
    drop_table :lead_event_rule_counts
    # Load previous migration
    require File.expand_path('../20120515194445_add_lead_scoring_rules.rb', __FILE__)
    migration = AddLeadScoringRules.new
    # Only create tables (don't re-add columns to app tables)
    migration.class_eval do
      def add_column(table, column, type, options)
        puts "-- not re-adding '#{column}' column to '#{table}' table."
      end
    end
    # Run migration
    migration.up
  end
end
