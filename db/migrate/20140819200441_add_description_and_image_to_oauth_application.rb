class AddDescriptionAndImageToOauthApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :description, :string
    add_column :oauth_applications, :image, :string
  end
end
