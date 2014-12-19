class AddTosToOauthApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :federal_agency, :boolean
    add_column :oauth_applications, :federal_agency_tos, :boolean
  end
end
