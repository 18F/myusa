class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string   :name
      t.datetime :completed_at
      t.integer  :user_id
      t.datetime :created_at,   :null => false
      t.datetime :updated_at,   :null => false
      t.integer  :app_id
    end

    add_index "tasks", ["app_id"], :name => "index_tasks_on_app_id"
    add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"
  end
end
