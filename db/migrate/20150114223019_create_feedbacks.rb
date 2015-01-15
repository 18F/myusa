class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.references  :user
      t.string :email
      t.string :from
      t.string :message
      t.string :remote_ip
      t.timestamps
    end

    add_index :feedbacks, :remote_ip
    add_index :feedbacks, :created_at
  end
end
