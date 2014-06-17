require 'spec_helper'
include Warden::Test::Helpers

def create_confirmed_user_with_profile(email_or_hash = {})
  email_or_hash = {email: email_or_hash} unless email_or_hash.kind_of? Hash
  profile = email_or_hash.reverse_merge(email: 'joe@citizen.org', password: 'Password1',
                                        first_name: 'Joe', last_name: 'Citizen', is_student: true)
  user_create_hash = profile.select {|key,val| [:email, :password].member?(key)}
  user = User.create!(user_create_hash)
  profile_create_hash = profile.select {|key,val| Profile.new.methods.map(&:to_sym).select{ |m| m != :email }.member?(key)}
  user.profile = Profile.new(profile_create_hash)
  user.confirm!
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
