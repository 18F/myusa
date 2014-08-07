Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid2, :mongoid3, :mongo_mapper
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    # Put your resource owner authentication logic here.
    # Example implementation:
    # User.find_by_id(session[:user_id]) || redirect_to(new_user_session_url)
    # binding.pry
    # pp current_user
    # current_user || redirect_to(new_user_session_url)
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
  # enable_application_owner :confirmation => false

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  # default_scopes  :public
  # optional_scopes :write, :update

  optional_scopes 'verify_credentials', 'profile', 'profile.email', 'profile.first_name',
    'profile.last_name', 'notifications', 'tasks'
  # description: 'Verify application credentials', scope_name: 'verify_credentials', :scope_type => 'app'},
  # {name: 'Profile', description: 'Read your profile information', scope_name: 'profile', :scope_type => 'user'},
  # {name: 'Profile email', description: 'Read your email address', scope_name: 'profile.email', :scope_type => 'user'},
  # {name: 'Profile title', description: 'Read your title (Mr./Mrs./Miss, etc.)', scope_name: 'profile.title', :scope_type => 'user'},
  # {name: 'Profile first name', description: 'Read your first name', scope_name: 'profile.first_name', :scope_type => 'user'},
  # {name: 'Profile middle name', description: 'Read your middle name', scope_name: 'profile.middle_name', :scope_type => 'user'},
  # {name: 'Profile last name', description: 'Read your last name', scope_name: 'profile.last_name', :scope_type => 'user'},
  # {name: 'Profile suffic', description: 'Read your suffix (Sr./Jr./III, etc.)', scope_name: 'profile.suffix', :scope_type => 'user'},
  # {name: 'Profile address', description: 'Read your address', scope_name: 'profile.address', :scope_type => 'user'},
  # {name: 'Profile address (2)', description: 'Read your address (2)', scope_name: 'profile.address2', :scope_type => 'user'},
  # {name: 'Profile city', description: 'Read your city', scope_name: 'profile.city', :scope_type => 'user'},
  # {name: 'Profile state', description: 'Read your state', scope_name: 'profile.state', :scope_type => 'user'},
  # {name: 'Profile zip', description: 'Read your zip code', scope_name: 'profile.zip', :scope_type => 'user'},
  # {name: 'Profile phone number', description: 'Read your phone number', scope_name: 'profile.phone_number', :scope_type => 'user'},
  # {name: 'Profile mobile number', description: 'Read your mobile number', scope_name: 'profile.mobile_number', :scope_type => 'user'},
  # {name: 'Profile gender', description: 'Read your gender', scope_name: 'profile.gender', :scope_type => 'user'},
  # {name: 'Profile marital status', description: 'Read your marital status', scope_name: 'profile.marital_status', :scope_type => 'user'},
  # {name: 'Profile parent', description: 'Read your parent status', scope_name: 'profile.is_parent', :scope_type => 'user'},
  # {name: 'Profile student', description: 'Read your student status', scope_name: 'profile.is_student', :scope_type => 'user'},
  # {name: 'Profile veteran', description: 'Read your veteran status', scope_name: 'profile.is_veteran', :scope_type => 'user'},
  # {name: 'Profile retiree', description: 'Read your retiree status', scope_name: 'profile.is_retired', :scope_type => 'user'},
  # {name: 'Tasks', description: 'Create tasks in your account', scope_name: 'tasks', :scope_type => 'user'},
  # {name: 'Notifications', description: 'Send you notifications', scope_name: 'notifications', :scope_type => 'user'}

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
  # grant_flows %w(authorization_code implicit password client_credentials)

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
