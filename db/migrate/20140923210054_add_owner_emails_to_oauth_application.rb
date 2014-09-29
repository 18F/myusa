class AddOwnerEmailsToOauthApplication < ActiveRecord::Migration
  def up
    add_column :oauth_applications, :owner_emails, :string, :limit => 2000
    add_column :oauth_applications, :developer_emails, :string, :limit => 2000

    Doorkeeper::Application.reset_column_information

    Doorkeeper::Application.all.each do |a|
      owner_emails = a.owners.map(&:email).join(' ')
      a.update_column(:owner_emails, owner_emails)
    end
  end

  def down
    remove_column :oauth_applications, :owner_emails
    remove_column :oauth_applications, :developer_emails
  end
end
