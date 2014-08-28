class AddUserAction < ActiveRecord::Migration
  def change
    create_table :user_actions do |t|
      t.references  :user
      t.integer     :record_id
      t.string      :record_type
      t.string      :action
    end

    add_index :user_actions, :user_id
    add_index :user_actions, [:record_id, :record_type]
  end
end
