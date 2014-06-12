class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :email,                  default: "", null: false
      t.datetime :remember_created_at
      t.integer  :sign_in_count,          default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.string   :uid
      t.string   :encrypted_password,     default: "", null: false
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email
      t.integer  :failed_attempts,        default: 0
      t.string   :unlock_token
      t.datetime :locked_at

      t.timestamps
    end

    add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
    add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    add_index "users", ["uid"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
    add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end
end
