class AddScopesToDoorkeeperApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :scopes, :string, null: true
  end
end
