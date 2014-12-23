class AddTosToOauthApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :federal_agency, :boolean
    add_column :oauth_applications, :organization, :string
    add_column :oauth_applications, :terms_of_service_accepted, :boolean
  end
end
