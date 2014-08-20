class ChangeScopeLimit < ActiveRecord::Migration
  def change
  	change_column :oauth_applications, :scopes, :string, :limit => 2000, null: true
  end
end
