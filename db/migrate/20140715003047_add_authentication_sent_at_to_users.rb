class AddAuthenticationSentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_sent_at, :datetime
    remove_column :users, :authentication_token_sent_at
  end
end
