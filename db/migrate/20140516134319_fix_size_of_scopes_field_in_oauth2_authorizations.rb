class FixSizeOfScopesFieldInOauth2Authorizations < ActiveRecord::Migration
  def up
    change_table :oauth2_authorizations do |t|
      t.change :scope, :string, :limit => 2000
    end
  end

  def down
    change_table :oauth2_authorizations do |t|
      t.change :scope, :string, :limit => nil
    end
  end
end
