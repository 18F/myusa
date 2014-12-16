class CreateSmsCode < ActiveRecord::Migration
  def change
    create_table :sms_codes do |t|
      t.integer  :user_id
      t.string   :mobile_number
      t.string   :token
      t.datetime :confirmation_sent_at
      t.datetime :confirmed_at
      t.timestamps
    end
  end
end
