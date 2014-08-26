Doorkeeper.configure do
  orm :active_record

  resource_owner_authenticator do
    current_user || warden.authenticate!(:scope => :user)
  end

  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  # admin_authenticator do
  #   # Put your admin authentication logic here.
  #   # Example implementation:
  #   Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
  # end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  # access_token_expires_in 2.hours

  # Reuse access token for the same resource owner within an application (disabled by default)
  # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
  # reuse_access_token

  # Issue access tokens with refresh token (disabled by default)
  # use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  enable_application_owner :confirmation => false

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  # default_scopes  :public
  # optional_scopes :write, :update

  optional_scopes *(Profile.scopes + %w(notifications tasks))

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for more information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # native_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Specify what grant flows are enabled in array of Strings. The valid
  # strings and the flows they enable are:
  #
  # "authorization_code" => Authorization Code Grant Flow
  # "implicit"           => Implicit Grant Flow
  # "password"           => Resource Owner Password Credentials Grant Flow
  # "client_credentials" => Client Credentials Grant Flow
  #
  # If not specified, Doorkeeper enables all the four grant flows.
  #
  grant_flows %w(authorization_code)

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with trusted a application.
  # skip_authorization do |resource_owner, client|
  #   client.superapp? or resource_owner.admin?
  # end

  # WWW-Authenticate Realm (default "Doorkeeper").
  realm "MyUSA"

  # Allow dynamic query parameters (disabled by default)
  # Some applications require dynamic query parameters on their request_uri
  # set to true if you want this to be allowed
  # wildcard_redirect_uri false
end

# The following are a couple hacks to get Doorkeeper to support features that
# are important to MyUSA. We are currently investigating whether we can work
# the Doorkeeper maintainers to get these features implemented (or get a better
# way to add features) in the core Doorkeeper repository.
#
# Client Application Scopes:
#
# We added a `scopes` field to the Doorkeeper::Application model and here we
# include some scopes related utility functions (the model mix-in) and patch the
# PreAuthorization class to check both server (specified in this config file)
# and client application scopes.
#
# Client Sandbox (public/private applications):
#
# We added a `public` field to the Doorkeeper::Application model and have and a
# valid_for(...) method to Doorkeeper::OAuth::Client. We then patch the
# validate_client to check that method to ensure that the current user is
# allowed to use the current client application.

Doorkeeper::Application.class_eval do
  include Doorkeeper::Models::Scopes

  validate do |a|
    return if a.scopes.nil?
    unless Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(a.scopes_string.to_s, Doorkeeper.configuration.scopes)
      errors.add(:scopes, 'Invalid scope')
    end
  end
end

module OAuthValidations
  def initialize(server, client, resource_owner, attrs = {})
    super(server, client, attrs)
    @resource_owner = resource_owner
  end

  def validate_scopes
    super && Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(scope, client.application.scopes)
  end

  def validate_client
    client.present? && client.valid_for?(@resource_owner)
  end
end

Doorkeeper::OAuth::PreAuthorization.prepend OAuthValidations

module OAuthClientEnhancements
  def valid_for?(user)
    return true if application.public
    return user == application.owner
  end
end

Doorkeeper::OAuth::Client.send :include, OAuthClientEnhancements
