class AddMobleNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_number, :string
    add_column :users, :unconfirmed_mobile_number, :string
  end
end
