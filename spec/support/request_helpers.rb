require 'spec_helper'
include Warden::Test::Helpers

def create_confirmed_user_with_profile(args)
  profile = {
    email: 'joe@citizen.org',
    first_name: 'Joe', last_name: 'Citizen', is_student: true
  }.merge(args)

  user = User.create!(email: profile[:email])

  profile.delete(:email)

  user.profile = Profile.new(profile)
  user
end

def login(user)
  login_as user, scope: :user
end

def shared_api_methods
  def build_access_token(app)
    scopes = app.oauth_scopes.collect{ |s| s.scope_name }.join(" ")
    token = nil
    authorization = Songkick::OAuth2::Provider::Authorization.new(@user, 'response_type' => 'token', 'client_id' => app.oauth2_client.client_id, 'redirect_uri' => app.oauth2_client.redirect_uri, 'scope' => scopes)

    if authorization
      authorization.grant_access!
      token = authorization.access_token
    end

    token
  end

  before do
    @user = create_confirmed_user_with_profile(is_student: nil, is_retired: false)
    @app = App.create(:name => 'App1', :redirect_uri => "http://localhost/")
    @app.oauth_scopes = OauthScope.where(:scope_type => 'user')
  end
end
