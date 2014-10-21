class AddDataToUserAction < ActiveRecord::Migration
  def change
    add_column :user_actions, :data, :text
  end
end
