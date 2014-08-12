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
      # Redirect to the 'native_uri' so that Doorkeeper redirects us back to a token page in our app.
      a.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      a.scopes = client_application_scopes
    end
  end

  let(:oauth_client) do
    # Set up an OAuth2::Client instance for HTTP calls that happen outside of the Capybara context.
    # More detail here: https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem
    OAuth2::Client.new(client_app.uid, client_app.secret, site: 'http://www.example.com') do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
  end

  def visit_oauth_authorize_url
    visit(oauth_client.auth_code.authorize_url(
      redirect_uri: client_app.redirect_uri,
      scope: requested_scope,
      state: 'state'
    ))
  end

  shared_examples 'scope error' do
    scenario 'displays scope error message' do
      expect(@auth_page).to be_displayed
      expect(@auth_page).to have_error_message
      expect(@auth_page.error_message.text).to include('The requested scope is invalid, unknown, or malformed.')
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
        visit_oauth_authorize_url
      end

      scenario 'redirects to login page' do
        @sign_in_page = SignInPage.new
        expect(@sign_in_page).to be_displayed
      end

    end

    context 'when logged in' do
      before :each do
        login user
        visit_oauth_authorize_url
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

        scenario 'user can deny' do
          expect(@auth_page).to be_displayed
          @auth_page.cancel_button.click
          expect(JSON.parse(@auth_page.body)["error"]).to eq("access_denied")
        end

        scenario 'user can selecte scopes' do
          # Authorize the client app
          expect(@auth_page).to be_displayed
          @auth_page.scope_email_checkbox.set(false)
          @auth_page.allow_button.click

          # Retrieve the code
          expect(@token_page).to be_displayed
          code = @token_page.code.text

          # Turn the code into a token
          token = oauth_client.auth_code.get_token(code, redirect_uri: client_app.redirect_uri)
          expect(token["scope"]).to eq("profile.last_name")
        end

      end

      context 'with bad scope value' do
        let(:requested_scope) { 'foo bar baz' }

        it_behaves_like 'scope error'
      end

      context 'with scope not in client application scopes' do
        let(:requested_scope) { 'profile.city' }

        it_behaves_like 'scope error'
      end

    end
  end
end
