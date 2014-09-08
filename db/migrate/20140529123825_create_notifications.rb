class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.string   :subject
      t.text     :body
      t.datetime :received_at
      t.integer  :app_id
      t.integer  :user_id
      t.datetime :created_at,  :null => false
      t.datetime :updated_at,  :null => false
      t.datetime :deleted_at
      t.datetime :viewed_at
    end

    add_index "notifications", ["app_id"], :name => "index_messages_on_o_auth2_model_client_id"
    add_index "notifications", ["app_id"], :name => "index_notifications_on_app_id"
    add_index "notifications", ["deleted_at"], :name => "index_notifications_on_deleted_at"
    add_index "notifications", ["user_id"], :name => "index_messages_on_user_id"
  end
  
  def down
    drop_table :notifications
  end
end
