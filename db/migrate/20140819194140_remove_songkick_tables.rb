class RemoveSongkickTables < ActiveRecord::Migration
  def change
    drop_table :oauth2_clients
    drop_table :oauth2_authorizations
    drop_table :apps
  end
end
