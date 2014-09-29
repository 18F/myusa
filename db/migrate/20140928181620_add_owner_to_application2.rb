class AddOwnerToApplication2 < ActiveRecord::Migration
  class Membership < ActiveRecord::Base; end

  def change
    add_column :oauth_applications, :owner_id, :integer, null: true
    add_column :oauth_applications, :owner_type, :string, null: true

    Doorkeeper::Application.reset_column_information

    Doorkeeper::Application.all.each do |a|
      a.owner_id = Membership.where(oauth_application_id: a.id).first.user_id
      a.owner_type = 'User'
      a.save!
    end

  end
end
