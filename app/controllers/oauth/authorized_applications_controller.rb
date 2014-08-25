
# Oauth::AuthorizedApplicationsController
class Oauth::AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
  include ScopeGroups

  def index
    @authorizations = Doorkeeper::AccessToken.where(
      resource_owner_id: current_user.id, revoked_at: nil)
    super
  end
end
