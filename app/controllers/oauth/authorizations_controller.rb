class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  before_filter :display_not_me, only: [:new]
  skip_filter *_process_action_callbacks.map(&:filter), :only => [:redesign]

  layout 'redesign'

  def redesign
    require 'ostruct'

    def current_user
      user = OpenStruct.new
      user.profile = OpenStruct.new
      user.profile.first_name = "Firstname"
      user.profile.last_name = "Lastname"
      #user.profile.email = "elizabeth.goodman@gsa.gov"
      user.define_singleton_method(:has_role?) do |params|
        false
      end

      user
    end

    @pre_auth = OpenStruct.new
    @pre_auth.client = OpenStruct.new
    @pre_auth.client.application = OpenStruct.new
    @pre_auth.client.application.name = "Sample Application"
    @pre_auth.client.uid = "123456789"
    @pre_auth.redirect_uri = "fake_redirect_uri.org/redirect"
    @pre_auth.state = "fake_state"
    @pre_auth.response_type = "fake_response_type"
    @pre_auth.scope = "fake_scope"
    @pre_auth.scopes = %w(profile.first_name profile.last_name profile.email)
    @pre_auth.client.application.tos_link = "https://github.com/18F"
    @pre_auth.client.application.privacy_policy_link = "https://github.com/18F"

    @app_name = @pre_auth.client.application.name

    render :new
  end

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
