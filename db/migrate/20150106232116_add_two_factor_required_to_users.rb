class AddTwoFactorRequiredToUsers < ActiveRecord::Migration
  def change
    add_column :users, :two_factor_required, :boolean
  end
end
