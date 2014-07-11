class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    add_column :users, :authentication_token_sent_at, :datetime

    add_index "users", ["authentication_token"], name: "index_users_on_authentication_token"
  end
end
