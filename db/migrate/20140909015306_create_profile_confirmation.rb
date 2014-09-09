class CreateProfileConfirmation < ActiveRecord::Migration
  def change
    create_table :profile_confirmations do |t|
      t.references  :user
      t.references  :profile
      t.string      :profile_field
      t.string      :token
      t.datetime    :confirmation_sent_at
      t.datetime    :confirmed_at
      t.datetime    :invalidated_at
    end

    add_index :profile_confirmations, :user_id
    add_index :profile_confirmations, [:profile_id, :profile_field]
  end
end
