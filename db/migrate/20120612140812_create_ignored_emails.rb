class CreateIgnoredEmails < ActiveRecord::Migration
  def change
    create_table :ignored_emails do |t|
			t.string :email
		end
	end
end
