class AddPublicToDoorkeeperApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :public, :boolean, default: false
  end
end
