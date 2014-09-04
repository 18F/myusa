class ChangeReturnToLimit < ActiveRecord::Migration
  def change
    change_column :authentication_tokens, :return_to, :string, :limit => 2000
  end
end
