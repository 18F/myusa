class RemoveOwnerFromOauthApplication < ActiveRecord::Migration
  def change
    remove_column :oauth_applications, :owner_id, :integer, null: true
    remove_column :oauth_applications, :owner_type, :string, null: true
  end
end
