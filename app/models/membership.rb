class Membership < ActiveRecord::Base
  belongs_to :oauth_application, class_name: Doorkeeper::Application, autosave: true
  belongs_to :user

  before_destroy :destroy_orphaned_applications,
    # In order to prevent infinite recursion, do not destroy the application
    # (again) if this call to destroy comes from its association with the
    # application.
    unless: -> { destroyed_by_association.active_record == Doorkeeper::Application }

  private

  def destroy_orphaned_applications
    if oauth_application.present? && oauth_application.owners.all? {|owner| owner == user }
      oauth_application.destroy
    end
  end

end
