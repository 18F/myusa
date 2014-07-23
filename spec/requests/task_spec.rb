require 'spec_helper'

describe "API Requests" do
  
  shared_api_methods
  
  before do
    @token = build_access_token(@app)
  end
  describe "GET /api/tasks" do
    context "when token is valid" do
      context "when there are tasks for a user, some of which were created by the app making the request" do
        before do
          @task1 = Task.create!({:name => 'Task #1', :user_id => @user.id, :app_id => @app.id})
          @task1.task_items << TaskItem.create!(:name => 'Task item 1 (no url)')
          @task2 = Task.create!({:name => 'Task #2', :user_id => @user.id, :app_id => @app.id + 1})
          @task2.task_items << TaskItem.create!(:name => 'Task item 1 (with url)', :url => 'http://www.google.com')
        end

        it "should return the tasks that were created by the calling app" do
          response = get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}" }
          expect(response.status).to eq 200
          parsed_json = JSON.parse(response.body)
          expect(parsed_json.size).to eq 1
          expect(parsed_json.first["name"]).to eq "Task #1"
        end

        it "should return the task and task items" do
          response = get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}" }
          parsed_json = JSON.parse(response.body)
          expect(parsed_json.first['task_items'].first['name']).to eq "Task item 1 (no url)"
        end
      end
    end

    context "when the the app does not have the proper scope" do
      before do
        @app4 = App.create(:name => 'App4', :redirect_uri => "http://localhost/")
        @app4.oauth_scopes << OauthScope.find_by_scope_name('notifications')
        @token4 = build_access_token(@app4)
      end

      it "should return an error message" do
        response = get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token4}"}
        expect(response.status).to eq 403
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "You do not have permission to view tasks for that user."
      end
    end

    context "when the request does not have a valid token" do
      it "should return an error message" do
        response = get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        expect(response.status).to eq 401
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "Invalid token"
      end
    end
  end

  describe "POST /api/tasks" do
    context "when the caller has a valid token" do
      context "when the appropriate parameters are specified" do
        it "should create a new task for the user" do
          response = post "/api/tasks", {:task => { :name => 'New Task' }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 200
          parsed_json = JSON.parse(response.body)
          expect(parsed_json).to_not be_nil
          expect(parsed_json["name"]).to eq "New Task"
          expect(Task.where(:name => 'New Task', :user_id => @user_id, :app_id => @app.id).count).to eq 0
        end
      end

      context "when the required parameters are missing" do
        it "should return an error message" do
          response = post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 400
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "can't be blank"
        end
      end
    end

    context "when the request does not have a valid token" do
      it "should return an error message" do
        response = post "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        expect(response.status).to eq 401
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "Invalid token"
      end
    end
  end
  
  describe "PUT /api/task/:id" do
    context "when the caller has a valid token" do
      before do
        @task = Task.create!({:name => "Mega task", :completed_at => Time.now-1.day, :user_id => @user.id, :app_id => @app.id, :task_items_attributes => [{ :name => "Task item one" }]})
      end
      context "when valid parameters are used" do
        it "should update the task and task items" do
          response = put "/api/tasks/#{@task.id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => @task.task_items.first.id, :name => "Task item one" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 200
          parsed_json = JSON.parse(response.body)
          expect(parsed_json['name']).to eq "New Task"
          expect(parsed_json['task_items'].first['name']).to eq 'Task item one'
        end
      end

      context "when updating a task marked as completed" do
         before do
          @task = Task.create!({:name => "Mega completed task", :user_id => @user.id, :app_id => @app.id, :task_items_attributes => [{ :name => "Task item one" }]})
          @task.complete!
        end
        it "should no longer be marked as complete when specified" do
          response = put "/api/tasks/#{@task.id}", {:task => { :name => 'New Incomplete Task', :completed_at => nil, :task_items_attributes => [{ :id => @task.task_items.first.id, :name => "Task item one" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 200
          parsed_json = JSON.parse(response.body)
          expect(parsed_json['name']).to eq "New Incomplete Task"
          expect(parsed_json['task_items'].first['name']).to eq 'Task item one'
        end
      end
      context "when invalid parameters are used" do
        it "should return meaningful errors" do
          response = put "/api/tasks/#{@task.id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => "chicken", :name => "updated task item name" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
          expect(response.status).to eq 422
          parsed_json = JSON.parse(response.body)
          expect(parsed_json['message']).to eq "Invalid parameters. Check your values and try again."
        end
      end
    end
    context "when the caller does not have a valid token" do
      before do
        @task = Task.create!({:name => "Super task", :user_id => @user.id, :app_id => @app.id, :task_items_attributes => [{ :name => "Task item one" }]})
      end

      it "should return authorization error" do
        response = put "/api/tasks/#{@task.id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => @task.task_items.first.id, :name => "Task item one" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}_"}
        expect(response.status).to eq 401
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "Invalid token"
      end
    end
  end
  
  describe "GET /api/task/:id" do
    before do
      @task = Task.create!({:name => 'New Task', :user_id => @user.id, :app_id => @app.id})
      @task.task_items << TaskItem.new(:name => "Task Item #1")
      @task.task_items << TaskItem.new(:name => "Task Item #2", :url => 'http://valid_url.com')
      @task.save!
    end

    context "when the token is valid" do
      it "should retrieve the task" do
        response = get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
        expect(response.status).to eq 200
        parsed_json = JSON.parse(response.body)
        expect(parsed_json).to_not be_nil
        expect(parsed_json["name"]).to eq "New Task"
        expect(parsed_json["task_items"].first["name"]).to eq "Task Item #1"
        expect(parsed_json["task_items"].last["url"]).to eq "http://valid_url.com"
      end
    end

    context "when the request does not have a valid token" do
      it "should return an error message" do
        response = get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        expect(response.status).to eq 401
        parsed_json = JSON.parse(response.body)
        expect(parsed_json["message"]).to eq "Invalid token"
      end
    end
  end
  
  #The following are minimal tests for generating API Documentation
  describe "Group Task" do
    describe "POST /api/tasks" do
      it "Create a new task" do
        response = post "/api/tasks", {:task => { :name => 'New Task' }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
        expect(response.status).to eq 200
      end
    end
    
    describe "PUT /api/task/:id" do
      before do
        @task = Task.create!({:name => "Mega task", :completed_at => Time.now-1.day, :user_id => @user.id, :app_id => @app.id, :task_items_attributes => [{ :name => "Task item one" }]})
      end
      it "Update a task and task items" do
        response = put "/api/tasks/#{@task.id}", {:task => { :name => 'New Task' , :task_items_attributes => [{ :id => @task.task_items.first.id, :name => "Task item one" }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
        expect(response.status).to eq 200
      end
    end
    
    describe "GET /api/tasks" do
      before do
        @task1 = Task.create!({:name => 'Task #1', :user_id => @user.id, :app_id => @app.id})
        @task1.task_items << TaskItem.create!(:name => 'Task item 1 (no url)')
        @task2 = Task.create!({:name => 'Task #2', :user_id => @user.id, :app_id => @app.id + 1})
        @task2.task_items << TaskItem.create!(:name => 'Task item 1 (with url)', :url => 'http://www.google.com')
      end

      it "List all tasks and associated attributes" do
        response = get "/api/tasks", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}" }
        expect(response.status).to eq 200
      end
    end
    
    describe "GET /api/task/:id" do
      before do
        @task = Task.create!({:name => 'New Task', :user_id => @user.id, :app_id => @app.id})
        @task.task_items << TaskItem.new(:name => "Task Item #1")
        @task.task_items << TaskItem.new(:name => "Task Item #2", :url => 'http://valid_url.com')
        @task.save!
      end

      it "Retrieve a task" do
        response = get "/api/tasks/#{@task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
        expect(response.status).to eq 200
      end
    end
    
  end
  
end