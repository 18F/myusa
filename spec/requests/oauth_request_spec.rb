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

  context "when logged in" do
    before {login(@user)}
    describe "Authorize application" do
      it "should recieve a valid token" do
        auth = Songkick::OAuth2::Model::Authorization.for(@user, @app1_client_auth, {:response_type => 'code'})
        response = post("/oauth/authorize", "grant_type" => "authorization_code", "code" => auth.code, "client_id" => @app1_client_auth.client_id, "client_secret" => @app1_client_auth.client_secret, "redirect_uri" => "http://localhost/")
        response.status.should == 200
        response.body.should match /access_token/
      end
    end

    describe "Authorize application with scopes" do
      context "when logged into an app" do
        it "should allow the app to redirect on logout with a registered URL" do
          pending "sign out not implemented"
          login(@user)
          test_url = 'http://app1host.com'
          get(sign_out_path(continue: test_url)).should redirect_to(test_url)
          
          login(@user)
          test_url = 'http://www.app1host.com'
          get(sign_out_path(continue: test_url)).should redirect_to(test_url)
        end

        it "should not allow the app to redirect on logout with an invalid url" do
          pending "sign out not implemented"
          login(@user)
          test_url = 'http://xyz'
          get(sign_out_path(continue: test_url)).should redirect_to(sign_in_url)
        end

        it "should not allow the app to redirect on logout with an unregistered url" do
          pending "sign out not implemented"
          login(@user)
          test_url = 'http://apphost.com'
          get(sign_out_path(continue: test_url)).should redirect_to(sign_in_url)
        end
      end
    end
  end
end
