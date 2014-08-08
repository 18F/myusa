class AddUrlToOauthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :url, :string, null: true
  end
end
