class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to :oauth_application
      t.references :user
      t.string :member_type
      t.timestamps
    end
  end
end
