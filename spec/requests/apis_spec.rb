require 'spec_helper'

describe "Profiles Requests" do
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

  describe "GET /api/profile" do
    context "when the request has a valid token" do
      context "when the app does not have permission to read the user's profile" do
        before do
          @app.oauth_scopes.destroy_all
          @token = build_access_token(@app)
        end

        it "should return an error and message" do
          response = get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 403
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "You do not have permission to read that user's profile."
        end
      end

      context "when app has limited scope" do
        before do
          @limited_scope_app = App.create(:name => 'app_limited', :redirect_uri => "http://localhost/")
          @limited_scope_app.oauth_scopes = OauthScope.top_level_scopes.where(:scope_type => 'user')
          # Adding just one profile sub scope to test that only this one is presnt in json.
          @limited_scope_app.oauth_scopes << OauthScope.find_by_scope_name("profile.first_name")
          @token = build_access_token(@limited_scope_app)
        end

        it "should return JSON with only app requested user profile attritues in addition to an id and a unique identifier" do
          response = get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 200
          parsed_json = JSON.parse(response.body)
          expect(parsed_json).to_not be_nil
          expect(parsed_json["first_name"]).to eq 'Joe'
          expect(parsed_json["id"]).to_not be_nil
          expect(parsed_json["uid"]).to_not be_nil
          expect(parsed_json["email"]).to be_nil  # profile.first_name is the only profile subscope app is authorized to access.
          # ...
          expect(parsed_json["is_veteran"]).to be_nil  # profile.first_name is the only profile subscope app is authorized to access.
          expect(parsed_json["is_retired"]).to be_nil  # profile.first_name is the only profile subscope app is authorized to access.
        end
      end

      context "when app has all scopes" do
        before do
          @all_scopes_app = App.create(:name => 'app_all_scopes', :redirect_uri => "http://localhost/")
          @all_scopes_app.oauth_scopes = OauthScope.top_level_scopes.where(:scope_type => 'user')
          # Adding just one profile sub scope to test that only this one is presnt in json.
          @all_scopes_app.oauth_scopes.concat OauthScope.where("scope_name like ?", 'profile.%').all
          @token = build_access_token(@all_scopes_app)
        end

        it "should return JSON with only app requested user profile attritues in addition to an id and a unique identifier" do
          response = get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 200
          parsed_json = JSON.parse(response.body)
          expect(parsed_json).to_not be_nil
          expect(parsed_json["first_name"]).to eq 'Joe'
          expect(parsed_json["id"]).to_not be_nil
          expect(parsed_json["uid"]).to_not be_nil
          expect(parsed_json["email"]).to_not be_nil
          # ...
          expect(parsed_json["is_veteran"]).to be_nil # we did not specify a value for this
          expect(parsed_json["is_retired"]).to eq "0"
        end
      end

      context "when the user queried exists" do
        before do
          @token = build_access_token(@app)
        end

        context "when the schema parameter is set" do
          it "should render the response in a Schema.org hash" do
            response = get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            expect(response.status).to eq 200
            parsed_json = JSON.parse(response.body)
            expect(parsed_json).to_not be_nil
            expect(parsed_json["email"]).to eq 'joe@citizen.org'
          end
        end
      end
    end

    context "when the request does not have a valid token" do
      it "should return an error message" do
        response = get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        expect(response.status).to eq 401
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "Invalid token"
      end
    end
  end
  
  describe "POST /api/notifications" do
    before do
      @token = build_access_token(@app)
      @other_user = create_confirmed_user_with_profile(email: 'jane@citizen.org', first_name: 'Jane')
      @app2 = App.create!(:name => 'App2', :redirect_uri => "http://localhost:3000/")
      @app2.oauth_scopes << OauthScope.top_level_scopes
      login(@user)
      1.upto(14) do |index|
        @notification = Notification.create!({:subject => "Notification ##{index}", :received_at => Time.now - 1.hour, :body => "This is notification ##{index}.", :user_id => @user.id, :app_id => @app.id})
      end
      @other_user_notification = Notification.create!({:subject => 'Other User Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different user.', :user_id => @other_user.id, :app_id => @app.id})
      @other_app_notification = Notification.create!({:subject => 'Other App Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different app.', :user_id => @user.id, :app_id => @app2.id})
      @user.notifications.each{ |n| n.destroy(:force) }
      @user.notifications.reload
    end

    context "when the user has a valid token" do
      context "when the notification attributes are valid" do
        it "should create a new notification when the notification info is valid" do
          expect(@user.notifications.size).to eq 0         
          response = post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 200
          @user.notifications.reload
          expect(@user.notifications.size).to eq 1
          expect(@user.notifications.first.subject).to eq "Project MyUSA"
        end
      end

      context "when the notification attributes are not valid" do
        it "should return an error message" do
          response = post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 400
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["message"]["subject"]).to eq ["can't be blank"]
        end
      end
    end

    context "when the the app does not have the proper scope" do
      before do
        @app3 = App.create(:name => 'App3', :redirect_uri => "http://localhost/")
        @app3.oauth_scopes << OauthScope.find_by_scope_name('tasks')
        @token3 = build_access_token(@app3)
      end

      it "should return an error message" do
        response = post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token3}"}
        expect(response.status).to eq 403
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "You do not have permission to send notifications to that user."
      end
    end

    context "when the user has an invalid token" do
      it "should return an error message" do
        response = post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer fake_token"}
        expect(response.status).to eq 401
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["message"]).to eq "Invalid token"
      end
    end
  end

end
