require 'spec_helper'

describe "OauthApps" do
  let(:user) { create_confirmed_user_with_profile(email: 'first@user.org') }
  let(:sandbox) do 
    App.create({name:  'sandbox', custom_text: 'Sandboxy custom message', user_id: user.id, redirect_uri: "http://sandboxhost.com/"})
  end

  before do
    @redirect_uri = 'http://localhost/'
    @app1 = App.create(name: 'App1', custom_text: 'Custom text for test'){|app| app.redirect_uri = "http://localhost/"; app.url="http://app1host.com"}
    @app1.is_public = true
    @app1.save!
    @app1_scopes = ['profile', 'notifications', 'tasks', 'profile.email', 'profile.middle_name']
    @app1.oauth_scopes = OauthScope.where(scope_name: @app1_scopes)
    @app1_client_auth = @app1.oauth2_client
  end

  context "when logged in with a user who owns a sandboxed app" do
    before {login(user)}

    describe "Authorize sandbox application by owner" do
      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: sandbox.oauth2_client.client_id, redirect_uri: 'http://sandboxhost.com/'))
        page.should have_content('The sandbox application wants to:')
        click_button('Allow')
        uri = URI.parse(current_url)
        params = CGI::parse(uri.query)
        code = (params["code"] || []).first
        expect(code).to_not be_empty
      end

      it "should log the sandbox application authorization activity, associated with the user" do
        pending "app activity logs not added"
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: sandbox.oauth2_client.client_id, redirect_uri: 'http://sandboxhost.com/'))
        expect(page).to  have_content('The sandbox application wants to:')
        click_button('Allow')
        expect(user.app_activity_logs.count).to_eq 1
        expect(user.app_activity_logs.first.app).to_eq @sandbox
      end
    end
  end

  context "when logged in with a user who does not own the sandboxed app" do
    before do
      @user2 = create_confirmed_user_with_profile(email: 'second@user.org')
      login(@user2)
    end

    describe "Does not allow sandbox application installation by non owner" do
      it "code in params should not have a value" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: sandbox.oauth2_client.client_id, redirect_uri: 'http://sandboxhost.com/'))
        expect(page).to  have_content("You are accessing an application that doesn't exist or hasn't given you sufficient access.")
      end
    end
  end

  context "when NON logged in with a user who does not own the sandboxed app" do
    describe "Does not allow sandbox application installation by non owner" do
      it "should present the login page" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: sandbox.oauth2_client.client_id, redirect_uri: 'http://sandboxhost.com/'))
        page.should have_content("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "Authorize application" do
    context "when the app is known" do
      it "should redirect to a login page to authorize a new app" do
        visit (url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/')
        )
        (current_path).should == new_user_session_path
        expect(page).to have_content('Sign in with Google')
      end
    end

    context "when the app is not known" do
      it "should redirect to a friendly error page if the app is unknown" do
        visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', client_id: 'xyz', redirect_uri: 'http://localhost/')
        )
        expect(page).to have_content("We're Sorry")
        expect(page).to have_content("You are accessing an application that doesn't exist or hasn't given you sufficient access.")
      end
    end
  end

  context "when logged in" do
    let(:app_client_auth) do
      app = App.create(name: 'App1', custom_text: 'Custom text') do |a|
        a.redirect_uri = 'http://localhost/'
        a.url = 'http://app1host.com'
        a.is_public = true
      end
      app.save!
      app.oauth2_client
    end
    before {login(user)}

    describe "Authorize application" do

      it "should log the application authorization activity, associated with the user" do
        pending "app activity logs not added"
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
        expect(page).to have_content('The App1 application wants to:')
        click_button('Allow')
        expect(user.app_activity_logs.count).to_eq 1
        expect(user.app_activity_logs.first.app).to_eq App.find_by_name('App1')
      end
    end

    describe "Authorize application with scopes" do

      let(:app_redirect_with_params) do 
        App.create(name: 'app_redirect_with_params') do |ar| 
          ar.redirect_uri = "http://apphost.com?something=true" 
          ar.is_public = true
          ar.oauth_scopes << OauthScope.top_level_scopes
          ar.oauth_scopes << OauthScope.where('scope_name = "profile.email"').first
        end
      end

      it "should not allow requests that contain unauthorized scopes" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', scope: 'profile notifications profile.email profile.address', client_id: @app1.client_id, redirect_uri: 'http://localhost/'))
        CGI::unescape(current_url).should have_content("#{@app1.oauth2_client.redirect_uri}?error=access_denied&error_description=#{I18n.t('unauthorized_scope')}")
      end

      it "should maintain original redirect_uri parameters (if present) when redirecting with unauthorized scopes error" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', scope: 'profile notifications profile.email profile.address', client_id: app_redirect_with_params.client_id, redirect_uri: 'http://apphost.com/'))
        app_redirect_url = URI.parse(app_redirect_with_params.oauth2_client.redirect_uri)
        app_redirect_url.query.should_not be_nil
        expect(current_url).to have_content(app_redirect_url.query)
        expect(current_url).to have_content("error=access_denied")
      end


      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', scope: 'profile notifications profile.email', client_id: @app1_client_auth.client_id, redirect_uri: @redirect_uri))
        expect(page).to have_content('The App1 application wants to:')
        expect(page).to have_content('Read your profile information')
        expect(page).to have_content('Send you notifications')
        expect(page).to have_content('Read your email address')
        expect(page).to_not have_content('Read your address')
        check('selected_scopes_profile')
        click_button('Allow')
        expect(page.current_url.split("?").first).to eq @redirect_uri
      end


      context "when the user does not approve" do
        it "should return an error when trying to authorize" do
          visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', scope: 'profile notifications', client_id: @app1_client_auth.client_id, redirect_uri: @redirect_uri))
          expect(page).to  have_content('The App1 application wants to:')
          expect(page).to  have_content('Read your profile information')
          expect(page).to  have_content('Send you notifications')
        end
      end
      
      context "when logged into an app" do
        before do
          visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', scope: 'profile notifications profile.email', client_id: @app1_client_auth.client_id, redirect_uri: @redirect_uri))
          expect(page).to have_content('The App1 application wants to:')
          expect(page).to have_content('Read your profile information')
          expect(page).to have_content('Send you notifications')
          expect(page).to have_content('Read your email address')
          expect(page).to_not have_content('Read your address')
        end
      end
    end
  end

  def auth_scopes(app, u)
    a = u.oauth2_authorizations.find { |auth| auth.client.try(:owner) == app }
    a.try(:scopes).try(:to_a) || []
  end

  describe 'user selected scopes' do
    let(:visit_authorize) do
      visit(url_for(
          controller: 'oauth',
          action: 'authorize',
          response_type: 'code',
          scope: @app1_scopes.join(' '),
          client_id: @app1_client_auth.client_id,
          redirect_uri: @redirect_uri))
    end

    before do
      login(user)
      # expect a user to have no scopes in the database
      expect(auth_scopes(@app1, user)).to be_blank
    end

    context 'user has profile data' do
      before do
        # expect user to have profile data
        expect(user.first_name).to be_present
        expect(user.email).to be_present
        visit_authorize
      end

      it 'user scopes should match requested scopes' do
        # uncheck no checkboxes
        click_button('Allow')
        user.reload
        # user scopes should match checked scopes
        expect(auth_scopes(@app1, user).sort).to eq @app1_scopes.sort
      end

      it 'user scopes should match only checked scopes' do
        # uncheck one checkboxes
        uncheck('selected_scopes_profile.email')
        click_button('Allow')
        user.reload
        # expect user scopes only be checked scopes
        app_scopes = @app1_scopes - ['profile.email']
        expect(auth_scopes(@app1, user).sort).to eq app_scopes.sort
      end
    end

    context 'user has incomplete user data' do
      before do
        # expect user to have incomlete profile data
        expect(user.profile.middle_name).to be_blank
        visit_authorize
      end

      it 'input box is presented for incomplete fields' do
        # input box is presented for incomplete fields
        puts current_url
        expect(page).to have_field('new_profile_values_profile.middle_name')
      end

      it 'checkbox is presented for complete fields' do
        # checkbox is presented for complete fields
        expect(page).to have_field('selected_scopes_profile.email')
      end

      it 'data from input box is persisted' do
        # fill in input
        fill_in 'new_profile_values_profile.middle_name', with: 'Example'
        # click allow
        click_button('Allow')
        user.reload
        # expect user data to be field data
        expect(user.profile.middle_name).to eq 'Example'
      end
    end
  end
end
