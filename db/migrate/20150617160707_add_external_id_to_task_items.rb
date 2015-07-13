class AddExternalIdToTaskItems < ActiveRecord::Migration
  def change
    add_column :task_items, :external_id, :string
  end
end
