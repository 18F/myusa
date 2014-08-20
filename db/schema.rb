# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140820180428) do

  create_table "app_oauth_scopes", force: true do |t|
    t.integer  "app_id"
    t.integer  "oauth_scope_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_oauth_scopes", ["app_id"], name: "index_app_oauth_scopes_on_app_id", using: :btree
  add_index "app_oauth_scopes", ["oauth_scope_id"], name: "index_app_oauth_scopes_on_oauth_scope_id", using: :btree

  create_table "authentications", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.text     "data"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["uid", "provider"], name: "index_authentications_on_uid_and_provider", using: :btree
  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "notifications", force: true do |t|
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

  add_index "notifications", ["app_id"], name: "index_messages_on_o_auth2_model_client_id", using: :btree
  add_index "notifications", ["app_id"], name: "index_notifications_on_app_id", using: :btree
  add_index "notifications", ["deleted_at"], name: "index_notifications_on_deleted_at", using: :btree
  add_index "notifications", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",                                      null: false
    t.string   "uid",                                       null: false
    t.string   "secret",                                    null: false
    t.text     "redirect_uri",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "url"
    t.string   "scopes",       limit: 2000
    t.boolean  "public",                    default: false
    t.string   "description"
    t.string   "image"
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "oauth_scopes", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "scope_name"
    t.string   "scope_type",  limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_scopes", ["scope_name"], name: "index_oauth_scopes_on_scope_name", using: :btree

  create_table "profiles", force: true do |t|
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

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "task_items", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "completed_at"
    t.integer  "task_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "task_items", ["task_id"], name: "index_task_items_on_task_id", using: :btree

  create_table "tasks", force: true do |t|
    t.string   "name"
    t.datetime "completed_at"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "app_id"
  end

  add_index "tasks", ["app_id"], name: "index_tasks_on_app_id", using: :btree
  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "uid"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.string   "authentication_token"
    t.datetime "authentication_sent_at"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
