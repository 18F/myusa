class AddTosLinkToApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :tos_link, :string
    add_column :oauth_applications, :privacy_policy_link, :string
  end
end
