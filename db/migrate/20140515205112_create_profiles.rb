class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.string :title
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :gender
      t.string :marital_status
      t.string :is_parent
      t.string :is_student
      t.string :is_veteran
      t.string :is_retired_string
      t.string :phone
      t.string :mobile

      t.timestamps
    end

    add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree
  end
end
