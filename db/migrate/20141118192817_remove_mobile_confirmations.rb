class RemoveMobileConfirmations < ActiveRecord::Migration
  def change
    drop_table "mobile_confirmations", force: true do |t|
      t.integer  "profile_id"
      t.string   "token"
      t.datetime "confirmation_sent_at"
      t.datetime "confirmed_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
    end
  end
end
