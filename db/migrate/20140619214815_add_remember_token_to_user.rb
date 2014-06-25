class AddRememberTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :remember_token, :string

    add_index "users", ["remember_token"], name: "index_users_on_remember_token"
  end
end
