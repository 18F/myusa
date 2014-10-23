class CreateUnsubscribeTokens < ActiveRecord::Migration
  def change
    create_table :unsubscribe_tokens do |t|
      t.references  :user
      t.references  :notification
      t.string      :token
      t.timestamps
    end
  end
end
