class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.references  :user
      t.references  :application
      t.text        :notification_settings
      t.timestamps
    end

    add_column :oauth_access_tokens, :authorization_id, :integer
    add_column :notifications, :authorization_id, :integer

    add_column :users, :notification_settings, :text
  end
end
