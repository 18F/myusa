class RemovePaperclipFromOauthApplications < ActiveRecord::Migration
  def self.up
    remove_column :oauth_applications, :image_file_name
    remove_column :oauth_applications, :image_content_type
    remove_column :oauth_applications, :image_file_size
    remove_column :oauth_applications, :image_updated_at
  end

  def self.down
    add_column :oauth_applications, :image_file_name, :string
    add_column :oauth_applications, :image_content_type, :string
    add_column :oauth_applications, :image_file_size, :integer
    add_column :oauth_applications, :image_updated_at, :datetime
  end
end
