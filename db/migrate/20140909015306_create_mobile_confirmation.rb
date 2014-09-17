class CreateMobileConfirmation < ActiveRecord::Migration
  def change
    create_table :mobile_confirmations do |t|
      t.belongs_to  :profile
      t.string      :token
      t.datetime    :confirmation_sent_at
      t.datetime    :confirmed_at
      t.timestamps
    end

    add_index :mobile_confirmations, :profile_id
  end
end
