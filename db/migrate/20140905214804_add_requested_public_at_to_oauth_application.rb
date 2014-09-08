class AddRequestedPublicAtToOauthApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :requested_public_at, :datetime
  end
end
