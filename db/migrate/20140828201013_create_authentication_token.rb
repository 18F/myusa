class CreateAuthenticationToken < ActiveRecord::Migration
  def change
    create_table :authentication_tokens do |t|
      t.integer     :user_id
      t.string      :token
      t.datetime    :sent_at
      t.boolean     :remember_me
      t.string      :return_to
    end

    add_index :authentication_tokens, :user_id
    add_index :authentication_tokens, :token, unique: true
  end
end
