class DropMemberships < ActiveRecord::Migration
  def change
    drop_table :memberships do |t|
      t.belongs_to :oauth_application
      t.references :user
      t.string :member_type
      t.timestamps
    end

    remove_column :oauth_applications, :owner_emails, :string, :limit => 2000
  end
end
