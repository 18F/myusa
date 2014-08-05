require 'rails_helper'

describe 'OauthApps' do

  let(:user) { create_confirmed_user_with_profile(email: 'somebody@user.org') }

  context 'when the user is logged in' do

    describe 'the client application' do
      let(:app_client_auth) do
        app = App.create(name: 'App1', custom_text: 'Custom text') do |a|
          a.redirect_uri = 'http://localhost/'
          a.url = 'http://app1host.com'
          a.is_public = true
        end
        app.save!
        app.oauth2_client
      end
      let(:auth) do
        Songkick::OAuth2::Model::Authorization.for(
          user, app_client_auth, response_type: 'code')
      end

      subject do
        post('/oauth/authorize',
             grant_type: 'authorization_code',
             code: auth.code,
             client_id: app_client_auth.client_id,
             client_secret: app_client_auth.client_secret,
             redirect_uri: 'http://localhost/')
      end

      describe 'receives a valid token' do
        its(:status) { should == 200 }
        its(:body)   { should include 'access_token' }
      end
    end
  end
end
