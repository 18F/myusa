class UpdateOauthAppsTable < ActiveRecord::Migration
  def self.up
    add_column :oauth_applications, :short_description, :string
    add_column :oauth_applications, :custom_text, :string
  	remove_column :oauth_applications, :image
    add_attachment :oauth_applications, :image
  end

  def self.down
    remove_column :oauth_applications, :short_description, :string
    remove_column :oauth_applications, :custom_text, :string
    remove_attachment :oauth_applications, :image
    add_column :oauth_applications, :image, :string
  end
end
