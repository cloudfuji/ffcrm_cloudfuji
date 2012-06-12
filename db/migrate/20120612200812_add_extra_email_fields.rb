class AddExtraEmailFields < ActiveRecord::Migration
  def change
    add_column :emails, :direction, :string
		add_column :emails, :imap_folder, :string
	end
end
