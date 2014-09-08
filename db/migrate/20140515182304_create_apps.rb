class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :short_description
      t.string :url
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at
      t.integer :user_id
      t.boolean :is_public, default: false
      t.datetime :deleted_at
      t.string :custom_text

      t.timestamps
    end

    add_index "apps", ["slug"], name: "index_apps_on_slug", using: :btree
  end
end
