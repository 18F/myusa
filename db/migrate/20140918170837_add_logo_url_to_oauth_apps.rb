class AddLogoUrlToOauthApps < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :logo_url, :string
  end
end
