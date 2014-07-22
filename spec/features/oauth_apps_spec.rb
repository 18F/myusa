require 'spec_helper'

describe "OauthApps" do
  before do
    @user = create_confirmed_user_with_profile(email: 'first@user.org')
    @user2 = create_confirmed_user_with_profile(email: 'second@user.org')

    @app_redirect_with_params = App.create(name: 'app_redirect_with_params'){|app| app.redirect_uri = "http://apphost.com?something=true"}
    @app_redirect_with_params.is_public = true
    @app_redirect_with_params.save!
    @app_redirect_with_params.oauth_scopes << OauthScope.top_level_scopes
    @app_redirect_with_params.oauth_scopes << OauthScope.where('scope_name = "profile.email"').first
    @app_redirect_with_params_client_auth = @app_redirect_with_params.oauth2_client

    @app1 = App.create(name: 'App1', custom_text: 'Custom text for test'){|app| app.redirect_uri = "http://localhost/"; app.url="http://app1host.com"}
    @app1.is_public = true
    @app1.save!
    @app1.oauth_scopes << OauthScope.top_level_scopes
    @app1.oauth_scopes << OauthScope.where('scope_name = "profile.email"').first
    @app1_client_auth = @app1.oauth2_client

    app2 = App.create(name: 'App2'){|app| app.redirect_uri = "http://app2host.com/"}
    app2.is_public = true
    app2.save!
    @app2_client_auth = app2.oauth2_client

    app3 = App.create(name:  'App3'){|app| app.redirect_uri = "http://app3host.com/"}
    app3.is_public = true
    app3.save!
    @app3_client_auth = app3.oauth2_client

    @sandbox = App.create({name:  'sandbox', custom_text: 'Sandboxy custom message', user_id: @user.id, redirect_uri: "http://sandboxhost.com/"})
    @sandbox_client_auth = @sandbox.oauth2_client
  end

  context "when logged in with a user who owns a sandboxed app" do
    before {login(@user)}

    describe "Authorize sandbox application by owner" do
      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://sandboxhost.com/'))
        page.should have_content('The sandbox application wants to:')
        click_button('Allow')
        uri = URI.parse(current_url)
        params = CGI::parse(uri.query)
        code = (params["code"] || []).first
        code.should_not be_empty
      end

      it "should log the sandbox application authorization activity, associated with the user" do
        pending "app activity logs not added"
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://sandboxhost.com/'))
        page.should have_content('The sandbox application wants to:')
        click_button('Allow')
        @user.app_activity_logs.count.should == 1
        @user.app_activity_logs.first.app.should == @sandbox
      end
    end
  end

  context "when logged in with a user who does not own the sandboxed app" do
    before {login(@user2)}

    describe "Does not allow sandbox application installation by non owner" do
      it "code in params should not have a value" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://sandboxhost.com/'))
        page.should have_content("You are accessing an application that doesn't exist or hasn't given you sufficient access.")
      end
    end
  end

  context "when NON logged in with a user who does not own the sandboxed app" do
    describe "Does not allow sandbox application installation by non owner" do
      it "should present the login page" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://sandboxhost.com/'))
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
        current_path.should eq new_user_session_path
        page.should have_content('Sign in with Google')
      end
    end

    context "when the app is not known" do
      it "should redirect to a friendly error page if the app is unknown" do
        visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', client_id: 'xyz', redirect_uri: 'http://localhost/')
        )
        page.should have_content("We're Sorry")
        page.should have_content("You are accessing an application that doesn't exist or hasn't given you sufficient access.")
      end
    end
  end

  context "when logged in" do
    before {login(@user)}

    describe "Authorize application" do

      it "should log the application authorization activity, associated with the user" do
        pending "app activity logs not added"
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The App1 application wants to:')
        click_button('Allow')
        @user.app_activity_logs.count.should == 1
        @user.app_activity_logs.first.app.should == App.find_by_name('App1')
      end
    end

    describe "Authorize application with scopes" do

      it "should not allow requests that contain unauthorized scopes" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', scope: 'profile notifications profile.email profile.address', client_id: @app1.client_id, redirect_uri: 'http://localhost/'))
        CGI::unescape(current_url).should have_content("#{@app1.oauth2_client.redirect_uri}?error=access_denied&error_description=#{I18n.t('unauthorized_scope')}")
      end

      it "should maintain original redirect_uri parameters (if present) when redirecting with unauthorized scopes error" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', scope: 'profile notifications profile.email profile.address', client_id: @app_redirect_with_params.client_id, redirect_uri: 'http://apphost.com/'))
        app_redirect_url = URI.parse(@app_redirect_with_params.oauth2_client.redirect_uri)
        app_redirect_url.query.should_not be_nil
        current_url.should have_content(app_redirect_url.query)
        current_url.should have_content("error=access_denied")
      end


      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', scope: 'profile notifications profile.email', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))

        page.should have_content('The App1 application wants to:')
        page.should have_content('Read your profile information')
        page.should have_content('Send you notifications')
        page.should have_content('Read your email address')
        page.should_not have_content('Read your address')
      end

      context "when the user does not approve" do
        it "should return an error when trying to authorize" do
          visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', scope: 'profile notifications', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
          page.should have_content('The App1 application wants to:')
          page.should have_content('Read your profile information')
          page.should have_content('Send you notifications')
        end
      end
      
      context "when logged into an app" do
        before do
          visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', scope: 'profile notifications profile.email', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))

          page.should have_content('The App1 application wants to:')
          page.should have_content('Read your profile information')
          page.should have_content('Send you notifications')
          page.should have_content('Read your email address')
          page.should_not have_content('Read your address')
        end
      end
    end
  end
end
