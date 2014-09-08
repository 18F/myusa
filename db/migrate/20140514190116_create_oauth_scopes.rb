class CreateOauthScopes < ActiveRecord::Migration
  def change
    create_table :oauth_scopes do |t|
      t.string   :name
      t.text     :description
      t.string   :scope_name
      t.string   :scope_type,  limit: 20

      t.timestamps
    end

    add_index "oauth_scopes", ["scope_name"], name: "index_oauth_scopes_on_scope_name", using: :btree
  end
end
