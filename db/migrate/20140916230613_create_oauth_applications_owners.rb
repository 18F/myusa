class CreateOauthApplicationsOwners < ActiveRecord::Migration
  def change
    create_table :oauth_applications_owners do |t|
      t.belongs_to :owner
      t.belongs_to :oauth_application
    end
  end
end
