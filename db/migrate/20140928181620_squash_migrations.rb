class SquashMigrations < ActiveRecord::Migration
  def change

      create_table "authentication_tokens" do |t|
        t.integer  "user_id"
        t.string   "token"
        t.datetime "sent_at"
        t.boolean  "remember_me"
        t.string   "return_to",   limit: 2000
      end

      add_index "authentication_tokens", ["token"], unique: true
      add_index "authentication_tokens", ["user_id"]

      create_table "authentications" do |t|
        t.string   "provider"
        t.string   "uid"
        t.text     "data"
        t.integer  "user_id"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "authentications", ["uid", "provider"]
      add_index "authentications", ["user_id"]

      create_table "mobile_confirmations" do |t|
        t.integer  "profile_id"
        t.string   "token"
        t.datetime "confirmation_sent_at"
        t.datetime "confirmed_at"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "mobile_confirmations", ["profile_id"]

      create_table "notifications" do |t|
        t.string   "subject"
        t.text     "body"
        t.datetime "received_at"
        t.integer  "app_id"
        t.integer  "user_id"
        t.datetime "created_at",  null: false
        t.datetime "updated_at",  null: false
        t.datetime "deleted_at"
        t.datetime "viewed_at"
      end

      add_index "notifications", ["app_id"]
      add_index "notifications", ["deleted_at"]
      add_index "notifications", ["user_id"]

      create_table "oauth_access_grants" do |t|
        t.integer  "resource_owner_id",              null: false
        t.integer  "application_id",                 null: false
        t.string   "token",                          null: false
        t.integer  "expires_in",                     null: false
        t.text     "redirect_uri",                   null: false
        t.datetime "created_at",                     null: false
        t.datetime "revoked_at"
        t.string   "scopes",            limit: 2000
      end

      add_index "oauth_access_grants", ["token"], unique: true

      create_table "oauth_access_tokens" do |t|
        t.integer  "resource_owner_id"
        t.integer  "application_id"
        t.string   "token",                          null: false
        t.string   "refresh_token"
        t.integer  "expires_in"
        t.datetime "revoked_at"
        t.datetime "created_at",                     null: false
        t.string   "scopes",            limit: 2000
      end

      add_index "oauth_access_tokens", ["refresh_token"], unique: true
      add_index "oauth_access_tokens", ["resource_owner_id"]
      add_index "oauth_access_tokens", ["token"], unique: true

      create_table "oauth_applications" do |t|
        t.string   "name",                                             null: false
        t.string   "uid",                                              null: false
        t.string   "secret",                                           null: false
        t.text     "redirect_uri",                                     null: false
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "url"
        t.string   "scopes",              limit: 2000
        t.boolean  "public",                           default: false
        t.string   "description"
        t.string   "short_description"
        t.string   "custom_text"
        t.datetime "requested_public_at"
        t.string   "logo_url"
        t.string   "developer_emails",    limit: 2000
        t.integer  "owner_id"
        t.string   "owner_type"
      end

      add_index "oauth_applications", ["uid"], unique: true

      create_table "oauth_scopes" do |t|
        t.string   "name"
        t.text     "description"
        t.string   "scope_name"
        t.string   "scope_type",  limit: 20
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "oauth_scopes", ["scope_name"]

      create_table "profiles" do |t|
        t.integer  "user_id"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "encrypted_title"
        t.string   "encrypted_first_name"
        t.string   "encrypted_middle_name"
        t.string   "encrypted_last_name"
        t.string   "encrypted_suffix"
        t.string   "encrypted_address"
        t.string   "encrypted_address2"
        t.string   "encrypted_city"
        t.string   "encrypted_state"
        t.string   "encrypted_zip"
        t.string   "encrypted_gender"
        t.string   "encrypted_marital_status"
        t.string   "encrypted_is_parent"
        t.string   "encrypted_is_student"
        t.string   "encrypted_is_veteran"
        t.string   "encrypted_is_retired"
        t.string   "encrypted_phone"
        t.string   "encrypted_mobile"
      end

      add_index "profiles", ["user_id"]

      create_table "task_items" do |t|
        t.string   "name"
        t.string   "url"
        t.datetime "completed_at"
        t.integer  "task_id"
        t.datetime "created_at",   null: false
        t.datetime "updated_at",   null: false
      end

      add_index "task_items", ["task_id"]

      create_table "tasks" do |t|
        t.string   "name"
        t.datetime "completed_at"
        t.integer  "user_id"
        t.datetime "created_at",   null: false
        t.datetime "updated_at",   null: false
        t.integer  "app_id"
      end

      add_index "tasks", ["app_id"]
      add_index "tasks", ["user_id"]

      create_table "user_actions" do |t|
        t.integer  "user_id"
        t.integer  "record_id"
        t.string   "record_type"
        t.string   "action"
        t.string   "remote_ip"
        t.datetime "created_at"
      end

      add_index "user_actions", ["record_id", "record_type"]
      add_index "user_actions", ["user_id"]

      create_table "users" do |t|
        t.string   "email",               default: "", null: false
        t.datetime "remember_created_at"
        t.integer  "sign_in_count",       default: 0
        t.datetime "current_sign_in_at"
        t.datetime "last_sign_in_at"
        t.string   "current_sign_in_ip"
        t.string   "last_sign_in_ip"
        t.string   "uid"
        t.string   "unconfirmed_email"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "remember_token"
      end

      add_index "users", ["email"], unique: true
      add_index "users", ["remember_token"]
      add_index "users", ["uid"], unique: true
  end
end
