class UpdateOauthAppsTable < ActiveRecord::Migration
  def self.up
    add_column :oauth_applications, :short_description, :string
    add_column :oauth_applications, :custom_text, :string
    add_column :oauth_applications, :image_file_name, :string
    add_column :oauth_applications, :image_content_type, :string
    add_column :oauth_applications, :image_file_size, :integer
    add_column :oauth_applications, :image_updated_at, :datetime
    remove_column :oauth_applications, :image
  end

  def self.down
    remove_column :oauth_applications, :short_description, :string
    remove_column :oauth_applications, :custom_text, :string
    remove_column :oauth_applications, :image_file_name
    remove_column :oauth_applications, :image_content_type
    remove_column :oauth_applications, :image_file_size
    remove_column :oauth_applications, :image_updated_at
    add_column :oauth_applications, :image, :string
  end
end
