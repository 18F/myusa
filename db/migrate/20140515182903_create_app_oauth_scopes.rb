class CreateAppOauthScopes < ActiveRecord::Migration
  def change
    create_table :app_oauth_scopes do |t|
      t.integer :app_id
      t.integer :oauth_scope_id

      t.timestamps
    end

    add_index "app_oauth_scopes", ["app_id"], name: "index_app_oauth_scopes_on_app_id", using: :btree
    add_index "app_oauth_scopes", ["oauth_scope_id"], name: "index_app_oauth_scopes_on_oauth_scope_id", using: :btree
  end
end
