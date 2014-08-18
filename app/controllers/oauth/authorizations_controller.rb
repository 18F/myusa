
# Oauth::AuthorizationsController
class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
prepend_before_action :redirect_to_tokens, only: [:create]

  def new
    # Check for address and address2
    pre_auth_scopes = pre_auth.scopes.to_a
    scopes = insert_extra_scope pre_auth_scopes,
                                'profile.address',
                                'profile.address2'

    # Sort array of scopes according to requirements
    pre_auth_scopes = scopes.sort_by do |x|
      SCOPE_GROUPS.map { |k| k[1] }.flatten.index x
    end

    @pre_auth_groups = create_groups pre_auth_scopes
    super
  end

  def create
    if params.has_key?(:profile)
      current_user.profile.tap do |profile|
        if !profile.update_attributes(profile_params)
          flash[:error] = profile.errors.full_messages.to_sentence
          redirect_to oauth_authorization_path(redirect_back_params)
          return
        end
      end
    end

    if params[:scope].is_a?(Array)
      params[:scope] = params[:scope].join(" ")
    end
    super
  end

  private
  def insert_extra_scope(arry, first, second)
    arry.push second if arry.include?(first) && !arry.include?(second)
    arry
  end

  def create_groups(pre_auth_scopes)
    pre_auth_groups = []

    SCOPE_GROUPS.keys.each do |group|
      inter = pre_auth_scopes & SCOPE_GROUPS[group]
      next if inter.empty?
      pre_auth_groups.push(
        name:   group,
        scopes: inter
      )
    end
    pre_auth_groups
  end

  def redirect_to_tokens
    # legacy implementation used POST /oauth/authorize for both the user facing
    # authorization screen and the API endpoint to request a token ... so, we
    # have to support it here.
    if params.has_key?(:grant_type)
      redirect_to oauth_token_path
    end
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
