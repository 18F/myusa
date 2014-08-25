
require 'feature_helper'

describe 'OAuth' do
  let(:user) { FactoryGirl.create(:user, email: 'testy.mctesterson@gsa.gov') }
  let(:client_app) { FactoryGirl.create(:application) }
  let(:client_app2) { FactoryGirl.create(:application, name: 'Client App 2') }
  let(:requested_scopes) { 'profile.email profile.last_name' }

  # Set up an OAuth2::Client instance for HTTP calls that happen outside of the
  # Capybara context. More detail here:
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem
  let(:oauth_client) do
    OAuth2::Client.new(client_app.uid, client_app.secret, site: 'http://www.example.com') do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
  end

  let(:oauth_client2) do
    # Set up an OAuth2::Client instance for HTTP calls that happen outside of the Capybara context.
    # More detail here: https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem
    OAuth2::Client.new(client_app2.uid, client_app2.secret, site: 'http://www.example.com/2') do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
  end

  def visit_oauth_authorize_url(client, app, scopes)
    visit(client.auth_code.authorize_url(
      redirect_uri: app.redirect_uri,
      scope: scopes,
      state: 'state'
    ))
  end

  shared_examples 'scope error' do
    scenario 'displays scope error message' do
      expect(@auth_page).to be_displayed
      expect(@auth_page).to have_oauth_error_message
      expect(@auth_page.oauth_error_message.text).to include('The requested scope is invalid, unknown, or malformed.')
    end
  end

  describe 'Authorizations' do
    let(:requested_scopes) do
      'profile.email profile.title profile.first_name profile.middle_name ' \
      'profile.last_name profile.phone_number profile.suffix profile.address ' \
      'profile.address2 profile.zip profile.gender profile.marital_status ' \
      'profile.is_parent profile.is_student profile.is_veteran ' \
      'profile.is_retired'
    end

    let(:client_application_scopes2) do
      'profile.email profile.phone_number profile.zip profile.gender ' \
      'profile.is_parent profile.is_student profile.is_veteran'
    end

    let(:requested_scopes2) do
      'profile.email profile.phone_number profile.zip profile.gender'
    end

    let(:client_app2) do
      FactoryGirl.create(:application, name: 'Client App 2',
                                       scopes: client_application_scopes2)
    end

    before :each do
      @auths_page = OAuth2::AuthorizationsPage.new
    end

    context 'when not logged in' do
      before :each do
        @auths_page.load
      end

      scenario 'redirects to login page' do
        @sign_in_page = SignInPage.new
        expect(@sign_in_page).to be_displayed
      end
    end

    context 'when logged in' do
      before :each do
        login user
        @auth_page = OAuth2::AuthorizationPage.new
        @token_page = OAuth2::TokenPage.new
        visit_oauth_authorize_url(oauth_client, client_app, requested_scopes)
        expect(@auth_page).to be_displayed
        @auth_page.allow_button.click

        # Retrieve the code
        expect(@token_page).to be_displayed
        code = @token_page.code.text

        # Turn the code into a token
        token = oauth_client.auth_code.get_token(code, redirect_uri: client_app.redirect_uri)
        expect(token).to_not be_expired
        client_app.redirect_uri = 'http://localhost:3000'
        client_app.save!

        visit_oauth_authorize_url(oauth_client2, client_app2, requested_scopes2)
        expect(@auth_page).to be_displayed
        @auth_page.allow_button.click

        # Retrieve the code
        expect(@token_page).to be_displayed
        code = @token_page.code.text

        # Turn the code into a token
        token = oauth_client2.auth_code.get_token(code, redirect_uri: client_app2.redirect_uri)
        expect(token).to_not be_expired

        @auths_page.load
      end

      it 'displays the authorizations' do
        #save_and_open_page
        expect(@auths_page).to be_displayed
        expect(@auths_page.first_app_title).to have_content 'Client App'
        
        expect(@auths_page.second_app_title).to have_content 'Client App 2'
      end
    end
  end

  describe 'Authorization' do
    before :each do
      @auth_page = OAuth2::AuthorizationPage.new
      @token_page = OAuth2::TokenPage.new
    end

    context 'when not logged in' do
      before :each do
        visit_oauth_authorize_url(oauth_client, client_app, requested_scopes)
      end

      scenario 'redirects to login page' do
        @sign_in_page = SignInPage.new
        expect(@sign_in_page).to be_displayed
      end

    end

    context 'when logged in' do
      before :each do
        login user
        visit_oauth_authorize_url(oauth_client, client_app, requested_scopes)
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

        scenario 'user can deny by clicking "No Thanks"' do
          expect(@auth_page).to be_displayed
          @auth_page.cancel_button.click
          expect(JSON.parse(@auth_page.body)["error"]).to eq("access_denied")
        end

        scenario 'user can deny by clicking "head back to" link' do
          expect(@auth_page).to be_displayed
          @auth_page.head_back_link.click
          expect(JSON.parse(@auth_page.body)["error"]).to eq("access_denied")
        end

        scenario 'user can select scopes' do
          expect(@auth_page).to be_displayed
          @auth_page.profile_email_checkbox.set(false)
          @auth_page.allow_button.click

          code = @token_page.code.text
          token = oauth_client.auth_code.get_token(code, redirect_uri: client_app.redirect_uri)
          expect(token["scope"]).to eq("profile.last_name")
        end

        scenario 'user can update profile' do
          expect(@auth_page).to be_displayed
          expect(@auth_page).to have_no_profile_email
          @auth_page.profile_last_name.set 'McTesterson'
          @auth_page.allow_button.click

          code = @token_page.code.text
          token = oauth_client.auth_code.get_token(code, redirect_uri: client_app.redirect_uri)
          profile = JSON.parse token.get('/api/profile').body
          expect(profile['last_name']).to eq('McTesterson')
          expect(profile['email']).to eq('testy.mctesterson@gsa.gov')
        end

        context 'profile data is invalid' do
          let(:client_app) { FactoryGirl.create(:application, scopes: 'profile.phone_number') }
          let(:requested_scopes) { 'profile.phone_number' }
          scenario 'user cannot save or authorize' do
            expect(@auth_page).to be_displayed
            @auth_page.profile_phone_number.set 'foobar'
            @auth_page.allow_button.click

            expect(@auth_page).to be_displayed
            expect(@auth_page.flash_error_message).to have_content("Phone number")
          end
        end
      end

      context "with lots of scopes" do
        let(:scopes) do
          'profile.email profile.title profile.first_name profile.middle_name ' \
          'profile.last_name profile.phone_number profile.suffix profile.address ' \
          'profile.address2 profile.zip profile.gender profile.marital_status ' \
          'profile.is_parent profile.is_student profile.is_veteran ' \
          'profile.is_retired'
        end
        let(:client_app) { FactoryGirl.create(:application, scopes: scopes) }
        let(:requested_scope) { scopes }

        it "user can authorize" do
          expect(@auth_page).to be_displayed
          @auth_page.allow_button.click

          expect(@token_page).to be_displayed
          code = @token_page.code.text

          token = oauth_client.auth_code.get_token(code, redirect_uri: client_app.redirect_uri)
          expect(token).to_not be_expired
        end
      end

      context 'with non-public (sandboxed) app' do
        let(:owner) { FactoryGirl.create(:user, email: 'owner@gsa.gov' )}
        let(:client_app) { FactoryGirl.create(:application, public: false, owner: owner) }

        context 'current user is client application owner' do
          let(:owner) { user }

          scenario 'user can authorize' do
            expect(@auth_page).to be_displayed
            @auth_page.allow_button.click

            expect(@token_page).to be_displayed
            code = @token_page.code.text

            token = oauth_client.auth_code.get_token(code, redirect_uri: client_app.redirect_uri)
            expect(token).to_not be_expired
          end
        end

        context 'current user is not client application owner' do
          scenario 'displays unknown application error' do
            expect(@auth_page).to be_displayed
            expect(@auth_page).to have_error_message
            expect(@auth_page.error_message.text).to include('Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method.')
          end
        end
      end

      context 'with bad scope value' do
        let(:requested_scopes) { 'foo bar baz' }

        it_behaves_like 'scope error'
      end

      context 'with scope not in client application scopes' do
        let(:requested_scopes) { 'profile.city' }

        it_behaves_like 'scope error'
      end

    end
  end

  # TODO move these specs to home page spec upon creation
  describe 'header and footer content' do
    let(:requested_scopes) { 'profile.email profile.last_name' }

    before :each do
      @auth_page = OAuth2::AuthorizationPage.new
      @token_page = OAuth2::TokenPage.new
    end

    context 'user is logged in' do
      before :each do
        login user
        visit_oauth_authorize_url(oauth_client, client_app, requested_scopes)
      end

      describe 'header and footer content' do
        it 'has settings menu' do
          expect(@auth_page).to have_settings
        end

        it 'does not have sign in button' do
          expect(@auth_page).to_not have_sign_in_button
        end

        it 'has footer content' do
          expect(@auth_page).to have_footer
        end

        it 'has ownership statement' do
          expect(@auth_page).to have_ownership
        end
      end
    end
  end
end
