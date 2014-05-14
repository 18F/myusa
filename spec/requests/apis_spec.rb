require 'spec_helper'

describe "Apis" do
  def build_access_token(app)
    # authorization = OAuth2::Model::Authorization.new
    # authorization.scope = app.oauth_scopes.collect{ |s| s.scope_name }.join(" ")
    # authorization.client = app.oauth2_client
    # authorization.owner = @user
    # authorization.save!
    # authorization.generate_access_token
    "access_token"
  end
  
  def create_confirmed_user_with_profile(options)
    "user"
  end

  before do
    @user = create_confirmed_user_with_profile(is_student: nil, is_retired: false)

    # @app = App.create(:name => 'App1', :redirect_uri => "http://localhost/")
    # @app.oauth_scopes = OauthScope.where(:scope_type => 'user')
    @app = "app"
  end

  describe "GET /api/credentials/verify" do
    before do
      # @verify_credentials_oauth_scope = OauthScope.find_or_create_by_name(:name => 'Verify credentials', :scope_name => 'verify_credentials', :scope_type => 'app')
      # 
      # @other_app = App.create(:name => 'Other App', :redirect_uri => "http://localhost")
      # @other_app.oauth_scopes << OauthScope.create(:name => 'App 1 API call', :scope_name => "app_1.api_call", :scope_type => 'user')
      # @other_app_access_token = build_access_token(@other_app)
      @other_app = "other app"
      @other_app_access_token = build_access_token(@other_app)
    end

    context "when the app does not have a valid token" do
      it "should return an error" do
        get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer BADTOKEN"}
        expect(response.code).to eq "401"
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "Invalid token"
      end
    end
    context "when the app has a valid access token, but does not have permission to verify credentials" do
      before do
        @app_access_token = build_access_token(@app)
      end

      it "should return an error message that informs the caller that they do not have the appropriate permissions" do
        get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
        expect(response.code).to eq "403"
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "You do not have permission to verify other application's credentials."
      end
    end
    context "when the app has permission to verify credentials" do
      before do
#        @app.oauth_scopes << @verify_credentials_oauth_scope
        @app_access_token = build_access_token(@app)
      end

      context "when the app attempts to verify credentials with an invalid scope" do
        it "should return an error" do
          get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "INVALID.SCOPE"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
          expect(response.code).to eq "400"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "The scope you are requesting to validate is not a recognized MyUSA scope; you may need to register your scope with MyUSA."
        end
      end

      context "when the app attempts to verify credentials with an access token that is invalid" do
        it "should return an error" do
          get "/api/credentials/verify", {:access_token => "INVALID TOKEN", :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
          expect(response.code).to eq "400"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "The access token you attempting to verify is not a valid access token."
        end
      end

      context "when the app attempts to verify credentials for a valid access token, but the access token does not have permission for the requested scope" do
        before do
#          @other_app.oauth_scopes.destroy_all
#          @other_app_access_token = build_access_token(@other_app)
          @other_app = "other app"
          @other_app_access_token = build_access_token(@other_app)
        end

        it "should return an error" do
          get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
          expect(response.code).to eq "403"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "The requesting application does not have access to app 1 api call for that user."
        end
      end

      context "when the app attempts to verify a valid access token and scope" do
        it "should return a valid response" do
          get "/api/credentials/verify", {:access_token => @other_app_access_token, :scope => "app_1.api_call"}, {'HTTP_AUTHORIZATION' => "Bearer #{@app_access_token}"}
          expect(response.code).to eq "200"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json).to be_empty
        end
      end
    end
  end
  describe "GET /api/profile" do
    before do
      @token = build_access_token(@app)
    end

    context "when the request has a valid token" do

      context "when the app does not have permission to read the user's profile" do
        before do
          #@app.oauth_scopes.destroy_all
          @token = build_access_token(@app)
        end

        it "should return an error and message" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.code).to eq "403"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "You do not have permission to read that user's profile."
        end
      end

      context "when app has limited scope" do
        before do
          #@limited_scope_app = App.create(:name => 'app_limited', :redirect_uri => "http://localhost/")
          #@limited_scope_app.oauth_scopes = OauthScope.top_level_scopes.where(:scope_type => 'user')
          # Adding just one profile sub scope to test that only this one is presnt in json.
          #@limited_scope_app.oauth_scopes << OauthScope.find_by_scope_name("profile.first_name")
          @limited_scope_app = "limited_scope_app"
          @token = build_access_token(@limited_scope_app)
        end

        it "should return JSON with only app requested user profile attritues in addition to an id and a unique identifier" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.code).to eq "200"
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
          #@all_scopes_app = App.create(:name => 'app_all_scopes', :redirect_uri => "http://localhost/")
          #@all_scopes_app.oauth_scopes = OauthScope.top_level_scopes.where(:scope_type => 'user')
          # Adding just one profile sub scope to test that only this one is presnt in json.
          #@all_scopes_app.oauth_scopes.concat OauthScope.where("scope_name like ?", 'profile.%').all
          @all_scopes_app = "all_scopes_app"
          @token = build_access_token(@all_scopes_app)
        end
        it "should return JSON with only app requested user profile attritues in addition to an id and a unique identifier" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.code).to eq "200"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json).to_not be_nil
          expect(parsed_json["first_name"]).to eq 'Joe'
          expect(parsed_json["id"]).to_not be_nil
          expect(parsed_json["uid"]).to_not be_nil
          expect(parsed_json["email"]).to_not be_nil
          # ...
          expect(parsed_json["is_veteran"]).to be_nil # we did not specify a value for this
          expect(parsed_json["is_retired"]).to eq false
        end
      end

      context "when the user queried exists" do
        it "should log the profile request" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          #log = AppActivityLog.find(:all, :order => :created_at).last
          #expect(log.action).to eq "show"
          #expect(log.controller).to eq "profiles"
          #expect(log.app.name).to eq "App1"
          #expect(log.user.email).to eq "joe@citizen.org"
        end

        context "when the schema parameter is set" do
          it "should render the response in a Schema.org hash" do
            get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            expect(response.code).to eq "200"
            parsed_json = JSON.parse(response.body)
            expect(parsed_json).to_not be_nil
            expect(parsed_json["email"]).to eq 'joe@citizen.org'
          end
        end
      end
    end

    context "when the request does not have a valid token" do
      it "should return an error message" do
        get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        expect(response.code).to eq "401"
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "Invalid token"
      end
    end
  end

  describe "POST /api/notifications" do
    before do
      @token = build_access_token(@app)
      @other_user = create_confirmed_user_with_profile(email: 'jane@citizen.org', first_name: 'Jane')
      #@app2 = App.create!(:name => 'App2', :redirect_uri => "http://localhost:3000/")
      #@app2.oauth_scopes << OauthScope.top_level_scopes
      #login(@user)
      #1.upto(14) do |index|
      #  @notification = Notification.create!({:subject => "Notification ##{index}", :received_at => Time.now - 1.hour, :body => "This is notification ##{index}.", :user_id => @user.id, :app_id => @app.id}, :as => :admin)
      #end
      #@other_user_notification = Notification.create!({:subject => 'Other User Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different user.', :user_id => @other_user.id, :app_id => @app.id}, :as => :admin)
      #@other_app_notification = Notification.create!({:subject => 'Other App Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different app.', :user_id => @user.id, :app_id => @app2.id}, :as => :admin)
      #@user.notifications.each{ |n| n.destroy(:force) }
      #@user.notifications.reload
    end

    context "when the user has a valid token" do
      context "when the notification attributes are valid" do
        it "should create a new notification when the notification info is valid" do
          #expect(@user.notifications.size).to eq 0
          post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.code).to eq "200"
          #@user.notifications.reload
          #expect(@user.notifications.size).to eq 1
          #expect(@user.notifications.first.subject).to eq "Project MyUSA"
        end
      end

      context "when the notification attributes are not valid" do
        it "should return an error message" do
          post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.code).to eq "400"
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["message"]["subject"]).to eq ["can't be blank"]
        end
      end
    end

    context "when the the app does not have the proper scope" do
      before do
        #@app3 = App.create(:name => 'App3', :redirect_uri => "http://localhost/")
        #@app3.oauth_scopes << OauthScope.find_by_scope_name('tasks')
        @app3 = "app3"
        @token3 = build_access_token(@app3)
      end

      it "should return an error message" do
        post "/api/notifications", {:notification => {:body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token3}"}
        expect(response.code).to eq "403"
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "You do not have permission to send notifications to that user."
      end
    end
    context "when the user has an invalid token" do
      it "should return an error message" do
        post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer fake_token"}
        expect(response.code).to eq "401"
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["message"]).to eq "Invalid token"
      end
    end
  end

  describe "Tasks API" do
    before do
      @token = build_access_token(@app)
    end

    describe "GET /api/tasks.json" do
      context "when token is valid" do
        context "when there are tasks for a user, some of which were created by the app making the request" do
          before do
            #@task1 = Task.create!({:name => 'Task #1', :user_id => @user.id, :app_id => @app.id}, :as => :admin)
            #@task1.task_items << TaskItem.create!(:name => 'Task item 1 (no url)')
            #@task2 = Task.create!({:name => 'Task #2', :user_id => @user.id, :app_id => @app.id + 1}, :as => :admin)
            #@task2.task_items << TaskItem.create!(:name => 'Task item 1 (with url)', :url => 'http://www.google.com')
          end

          it "should return the tasks that were created by the calling app" do
            get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}" }
            expect(response.code).to eq "200"
            parsed_json = JSON.parse(response.body)
            expect(parsed_json.size).to eq 1
            expect(parsed_json.first["name"]).to eq "Task #1"
          end

          it "should return the task and task items" do
            get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}" }
            parsed_json = JSON.parse(response.body)
            expect(parsed_json.first['task_items'].first['name']).to eq "Task item 1 (no url)"
          end
        end
      end

      context "when the the app does not have the proper scope" do
        before do
          #@app4 = App.create(:name => 'App4', :redirect_uri => "http://localhost/")
          #@app4.oauth_scopes << OauthScope.find_by_scope_name('notifications')
          @app4 = "app4"
          @token4 = build_access_token(@app4)
        end

        it "should return an error message" do
          get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token4}"}
          expect(response.code).to eq "403"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "You do not have permission to view tasks for that user."
        end
      end

      context "when the request does not have a valid token" do
        it "should return an error message" do
          get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
          expect(response.code).to eq "401"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "Invalid token"
        end
      end
    end

    describe "POST /api/tasks" do
      context "when the caller has a valid token" do
        context "when the appropriate parameters are specified" do
          it "should create a new task for the user" do
            post "/api/tasks", {:task => { :name => 'New Task' }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            expect(response.code).to eq "200"
            parsed_json = JSON.parse(response.body)
            expect(parsed_json).to_not be_nil
            expect(parsed_json["name"]).to eq "New Task"
            # expect(Task.find_all_by_name_and_user_id_and_app_id('New Task', @user.id, @app.id)).to_not be_nil
          end
        end

        context "when the required parameters are missing" do
          it "should return an error message" do
            post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            expect(response.code).to eq "400"
            parsed_json = JSON.parse(response.body)
            expect(parsed_json["message"]).to eq("name"=>["can't be blank"])
          end
        end
      end

      context "when the request does not have a valid token" do
        it "should return an error message" do
          post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
          expect(response.code).to eq "401"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "Invalid token"
        end
      end
    end

    describe "PUT /api/tasks:id.json" do
      context "when the caller has a valid token" do
        before do
          # @task = Task.create!({:name => "Mega task", :user_id => @user.id, :app_id => @app.id, :task_items_attributes => [{ :name => "Task item one" }]}, :as =>:admin)
        end
        context "when valid parameters are used" do
          it "should update the task and task items" do
            # task_id = @task.id
            task_item_id = @task.task_items.first.id
            task_id = 1
            task_item_id = 1
            put "/api/tasks/#{task_id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => task_item_id, :name => "new task item one" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            expect(response.code).to eq "200"
            parsed_json = JSON.parse(response.body)
            expect(parsed_json['name']).to eq "New Task"
            expect(parsed_json['task_items'].first['name']).to eq 'new task item one'
          end
        end

        context "when invalid parameters are used" do
          it "should return meaningful errors" do
            #task_id = @task.id
            task_id = 1
            put "/api/tasks/#{task_id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => "chicken", :name => "updated task item name" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            expect(response.code).to eq "422"
            parsed_json = JSON.parse(response.body)
            expect(parsed_json['message']).to eq "Invalid parameters. Check your values and try again."
          end
        end
      end

      context "when the caller does not have a valid token" do
        before do
          #@task = Task.create!({:name => "Super task", :user_id => @user.id, :app_id => @app.id, :task_items_attributes => [{ :name => "Task item one" }]}, :as =>:admin)
        end

        it "should return authorization error" do
          #task_id = @task.id
          #task_item_id = @task.task_items.first.id
          task_id = 1
          task_item_id = 1
          put "/api/tasks/#{task_id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => task_item_id, :name => "new task item one" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}_"}
          expect(response.code).to eq "401"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "Invalid token"
        end
      end
    end

    describe "GET /api/tasks/:id.json" do
      before do
        #@task = Task.create!({:name => 'New Task', :user_id => @user.id, :app_id => @app.id}, :as => :admin)
        #@task.task_items << TaskItem.new(:name => "Task Item #1")
        #@task.task_items << TaskItem.new(:name => "Task Item #2", :url => 'http://valid_url.com')
        #@task.save!
      end

      context "when the token is valid" do
        it "should retrieve the task" do
          # task_id = @task.id
          task_id = 1
          get "/api/tasks/#{task_id}", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.code).to eq "200"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json).to_not be_nil
          expect(parsed_json["name"]).to eq "New Task"
          expect(parsed_json["task_items"].first["name"]).to eq "Task Item #1"
          expect(parsed_json["task_items"].last["url"]).to eq "http://valid_url.com"
        end
      end

      context "when the request does not have a valid token" do
        it "should return an error message" do
          # task_id = @task.id
          task_id = 1
          get "/api/tasks/#{task_id}", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
          expect(response.code).to eq "401"
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "Invalid token"
        end
      end
    end
  end
end
