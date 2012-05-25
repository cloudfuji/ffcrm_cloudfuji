class AddIdoIdToLead < ActiveRecord::Migration
  def change
    add_column :leads, :ido_id, :text
  end
end
