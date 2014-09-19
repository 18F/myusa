class RemovePaperclipFromOauthApplications < ActiveRecord::Migration
  def self.up
    remove_attachment :oauth_applications, :image
  end

  def self.down
    add_attachment :oauth_applications, :image
  end
end
