class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  before_filter :display_not_me, only: [:new]
  skip_filter *_process_action_callbacks.map(&:filter)

  layout 'redesign'
  
  def new
    if pre_auth.authorizable?
      if matching_token? || skip_authorization?
        auth = authorization.authorize
        redirect_to auth.redirect_uri
      else
        render :new
      end
    else
      render :error
    end
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
