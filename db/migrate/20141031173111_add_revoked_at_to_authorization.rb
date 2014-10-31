class AddRevokedAtToAuthorization < ActiveRecord::Migration
  def change
    add_column :authorizations, :revoked_at, :datetime
  end
end
