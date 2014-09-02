class DropAppOauthScopes < ActiveRecord::Migration
  def change
    drop_table :app_oauth_scopes
  end
end
