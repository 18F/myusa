require 'spec_helper'

describe "API Requests" do

  shared_api_methods
  
  describe 'Group Notification' do
    describe 'POST /api/v1/notifications' do
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
  
end