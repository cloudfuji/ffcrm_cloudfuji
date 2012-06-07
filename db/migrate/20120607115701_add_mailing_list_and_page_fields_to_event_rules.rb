class AddMailingListAndPageFieldsToEventRules < ActiveRecord::Migration
  def change
    add_column :event_rules, :mailing_list, :string
    add_column :event_rules, :mailing_list_group, :string
    add_column :event_rules, :mailing_list_grouping, :string

    add_column :event_rules, :page_name, :string
    add_column :event_rules, :app_id, :string

    # TODO - There's no way to figure out which user to use based on a received event... ??
    # Just making the Umi user's ido_id field temporarily part of the event rule form, for now.
    add_column :event_rules, :user_ido_id, :string
  end
end
