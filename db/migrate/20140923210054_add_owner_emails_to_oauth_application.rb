class AddOwnerEmailsToOauthApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :owner_emails, :string, :limit => 2000
    add_column :oauth_applications, :developer_emails, :string, :limit => 2000
  end
end
