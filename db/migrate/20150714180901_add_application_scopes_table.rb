class AddApplicationScopesTable < ActiveRecord::Migration
  def change
  	create_table "oauth_application_scopes", force: true do |t|
      t.integer :application_id
    	t.string :name
      t.text :reason_needed
    end

    add_index :oauth_application_scopes, :application_id
    add_index :oauth_application_scopes, [:application_id, :name], :unique => true
  end
end
