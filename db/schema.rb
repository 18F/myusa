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

ActiveRecord::Schema.define(version: 20140529184147) do

  create_table "app_oauth_scopes", force: true do |t|
    t.integer  "app_id"
    t.integer  "oauth_scope_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_oauth_scopes", ["app_id"], name: "index_app_oauth_scopes_on_app_id", using: :btree
  add_index "app_oauth_scopes", ["oauth_scope_id"], name: "index_app_oauth_scopes_on_oauth_scope_id", using: :btree

  create_table "apps", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.string   "short_description"
    t.string   "url"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "user_id"
    t.boolean  "is_public",         default: false
    t.datetime "deleted_at"
    t.string   "custom_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apps", ["slug"], name: "index_apps_on_slug", using: :btree

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

  create_table "oauth2_authorizations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth2_resource_owner_type"
    t.integer  "oauth2_resource_owner_id"
    t.integer  "client_id"
    t.string   "scope",                      limit: 2000
    t.string   "code",                       limit: 40
    t.string   "access_token_hash",          limit: 40
    t.string   "refresh_token_hash",         limit: 40
    t.datetime "expires_at"
  end

  add_index "oauth2_authorizations", ["access_token_hash"], name: "index_oauth2_authorizations_on_access_token_hash", unique: true, using: :btree
  add_index "oauth2_authorizations", ["client_id", "code"], name: "index_oauth2_authorizations_on_client_id_and_code", unique: true, using: :btree
  add_index "oauth2_authorizations", ["client_id", "oauth2_resource_owner_type", "oauth2_resource_owner_id"], name: "index_owner_client_pairs", unique: true, using: :btree
  add_index "oauth2_authorizations", ["client_id", "refresh_token_hash"], name: "index_oauth2_authorizations_client_id_refresh_token_hash_u", unique: true, using: :btree

  create_table "oauth2_clients", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth2_client_owner_type"
    t.integer  "oauth2_client_owner_id"
    t.string   "name"
    t.string   "client_id"
    t.string   "client_secret_hash"
    t.string   "redirect_uri"
  end

  add_index "oauth2_clients", ["client_id"], name: "index_oauth2_clients_on_client_id", unique: true, using: :btree
  add_index "oauth2_clients", ["name"], name: "index_oauth2_clients_on_name", unique: true, using: :btree

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
    t.string   "title"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "suffix"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "gender"
    t.string   "marital_status"
    t.string   "is_parent"
    t.string   "is_student"
    t.string   "is_veteran"
    t.string   "is_retired"
    t.string   "phone"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "encrypted_password",     default: "", null: false
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
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
