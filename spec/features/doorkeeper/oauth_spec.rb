require 'feature_helper'

describe 'OAuth' do

  let(:user) do
    User.create! do |u|
      u.email = 'testy.mctesterson@gsa.gov'
    end
  end

  let(:client_application_scopes) { 'profile.email profile.first_name profile.last_name' }

  let(:client_app) do
    Doorkeeper::Application.create do |a|
      a.name = 'Client App'
      a.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      a.scopes = client_application_scopes
    end
  end

  let(:oauth_client) do
    OAuth2::Client.new(client_app.uid, client_app.secret, site: 'http://www.example.com') do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
  end


  describe 'Authorization' do
    let(:requested_scope) { 'profile.email profile.last_name' }

    before :each do
      @auth_page = OAuth2::AuthorizationPage.new
      @token_page = OAuth2::TokenPage.new
    end

    context 'when not logged in' do
      before :each do
        visit oauth_client.auth_code.authorize_url(
          redirect_uri: client_app.redirect_uri,
          scope: requested_scope,
          state: 'state'
        )
      end

      scenario 'redirects to login page' do
        @sign_in_page = SignInPage.new
        expect(@sign_in_page).to be_displayed
      end

    end

    context 'when logged in' do
      before :each do
        login user

        visit oauth_client.auth_code.authorize_url(
          redirect_uri: client_app.redirect_uri,
          scope: requested_scope,
          state: 'state'
        )
      end

      context 'with valid url params' do
        scenario 'user can authorize' do
          # Authorize the client app
          expect(@auth_page).to be_displayed
          @auth_page.allow_button.click

          # Retrieve the code
          expect(@token_page).to be_displayed
          code = @token_page.code.text

          # Turn the code into a token
          token = oauth_client.auth_code.get_token(code, redirect_uri: client_app.redirect_uri)
          expect(token).to_not be_expired
        end

        scenario 'user can select scopes' do
          # Authorize the client app
          expect(@auth_page).to be_displayed
          @auth_page.scopes.uncheck('Read your email address')
          @auth_page.allow_button.click

          # Retrieve the code
          expect(@token_page).to be_displayed
          code = @token_page.code.text

          # Turn the code into a token
          token = oauth_client.auth_code.get_token(code, redirect_uri: client_app.redirect_uri)
          expect(token["scope"]).to eq("profile.last_name")
        end

      end

      context 'with non-public (sandboxed) app' do
        let(:owner) do
          User.create do |u|
            u.email = 'owner.mctesterson@gsa.gov'
          end
        end

        let(:client_app) do
          Doorkeeper::Application.create do |a|
            a.name = 'Client App'
            a.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
            a.scopes = client_application_scopes
            a.owner = owner
            a.public = false
          end
        end

        pending 'displays unknown application error' do
          expect(@auth_page).to be_displayed
          expect(@auth_page).to have_error_message
          expect(@auth_page.error_message.text).to include('Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method.')
        end
      end

      context 'with bad scope value' do
        let(:requested_scope) { 'foo bar baz' }

        scenario 'displays scope error' do
          expect(@auth_page).to be_displayed
          expect(@auth_page).to have_error_message
          expect(@auth_page.error_message.text).to include('The requested scope is invalid, unknown, or malformed.')
        end
      end

      context 'with scope not in client application scopes' do
        let(:requested_scope) { 'profile.city' }

        scenario 'displays scope error' do
          expect(@auth_page).to be_displayed
          expect(@auth_page).to have_error_message
          expect(@auth_page.error_message.text).to include('The requested scope is invalid, unknown, or malformed.')
        end
      end

    end
  end
end
