class Oauth::AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
  layout 'dashboard'

  helper :all

  def index
    @authorizations = current_user.authorizations.not_revoked
    @applications = current_user.oauth_applications
  end

  def destroy
    Doorkeeper::AccessToken.revoke_all_for params[:id], current_resource_owner
    redirect_to authorizations_path, notice: I18n.t(
      :notice, scope: [:doorkeeper, :flash, :authorized_applications, :destroy])
  end
end
