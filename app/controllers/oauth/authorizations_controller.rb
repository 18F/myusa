
# Oauth::AuthorizationsController
class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  before_filter :pre_auth, only: [:new]
  before_filter :display_not_me, only: [:new]

  layout 'dashboard'

  def index
    @authorizations = Doorkeeper::AccessToken.where(
      resource_owner_id: current_user.id, revoked_at: nil)
    @applications = current_user.oauth_applications
  end

  def create
    if params.key?(:profile)
      current_user.profile.tap do |profile|
        unless profile.update_attributes(profile_params)
          flash[:error] = profile.errors.full_messages.to_sentence
          redirect_to oauth_authorization_path(redirect_back_params)
          return
        end
      end
    end
    params[:scope] = params[:scope].join(' ') if params[:scope].is_a?(Array)
    super
  end

  private

  def display_not_me
    @display_not_me = true
  end

  def profile_params
    params.require(:profile).permit(Profile::FIELDS + Profile::METHODS)
  end

  def redirect_back_params
    params.slice(
      'client_id', 'redirect_uri', 'state', 'response_type'
    ).merge(scope: params[:original_scope])
  end

  def pre_auth
    @pre_auth ||= Doorkeeper::OAuth::PreAuthorization.new(Doorkeeper.configuration, server.client_via_uid, current_resource_owner, params)
  end
end
