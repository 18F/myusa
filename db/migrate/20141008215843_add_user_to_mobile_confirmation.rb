class AddUserToMobileConfirmation < ActiveRecord::Migration
  def change
    add_column :mobile_confirmations, :user_id, :integer
  end
end
