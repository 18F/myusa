class CreateTaskItems < ActiveRecord::Migration
  def change
    create_table :task_items do |t|
      t.string   :name
      t.string   :url
      t.datetime :completed_at
      t.integer  :task_id
      t.datetime :created_at,   :null => false
      t.datetime :updated_at,   :null => false
    end

    add_index "task_items", ["task_id"], :name => "index_task_items_on_task_id"
  end
end
