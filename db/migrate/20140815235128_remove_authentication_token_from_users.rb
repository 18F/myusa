class RemoveAuthenticationTokenFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :authentication_token
    remove_column :users, :authentication_sent_at
  end
end
