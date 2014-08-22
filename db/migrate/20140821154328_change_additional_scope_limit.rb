class ChangeAdditionalScopeLimit < ActiveRecord::Migration
  def change
    change_column :oauth_access_grants, :scopes, :string, :limit => 2000, null: true
    change_column :oauth_access_tokens, :scopes, :string, :limit => 2000, null: true
  end
end

