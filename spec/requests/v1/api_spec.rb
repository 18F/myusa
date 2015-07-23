require 'spec_helper'

describe Api::V1 do
  let(:client_app) { FactoryGirl.create(:application) }
  let(:user) { FactoryGirl.create(:user, :with_profile) }
  let(:scopes) { '' }
  let(:token) { FactoryGirl.create(:access_token, application: client_app, resource_owner: user, scopes: scopes) }
  let(:header) { { 'HTTP_AUTHORIZATION' => "Bearer #{token.token}" } }
  let(:empty_header) { {} }

  describe 'Legacy tokens path' do
    let(:grant) do
      FactoryGirl.create(:access_grant,
                         application: client_app,
                         redirect_uri: client_app.redirect_uri,
                         resource_owner: user)
    end

    let(:params) do
      {
        client_id: client_app.uid,
        client_secret: client_app.secret,
        code: grant.token,
        grant_type: 'authorization_code',
        redirect_uri: client_app.redirect_uri
      }
    end

    subject { post '/oauth/authorize', params }
    it 'response http code is 200' do
      expect(subject.status).to eql(200)
    end
    it 'response should have an access token' do
      expect(JSON.parse(subject.body)).to have_key('access_token')
    end
  end

  describe 'Token validity check' do
    subject { get '/api/v1/profile', nil, header }
    context 'with a valid token' do
      let(:scopes) { 'profile.email' }
      its(:status) { should eq 200 }
    end
    context 'with an invalid token' do
      let(:token)  { double(:access_token, token: 'bad token! No cookie!') }
      its(:status) { should eq 401 }
      it 'should include an error message' do
        expect(JSON.parse(subject.body)['message']).to eql 'Not Authorized'
      end
    end
  end

  describe 'GET /api/v1/tokeninfo' do
    let(:path)   { '/api/v1/tokeninfo' }
    let(:scopes) { 'profile.first_name profile.last_name' }
    describe "response status" do
      subject { get path, nil, header }
      its(:status) { should eq 200 }
    end
    describe "response body" do
      subject { JSON.parse(get(path, nil, header).body) }
      its(['resource_owner_id'])  { should eq user.id }
      its(['scopes'])             { should eq scopes.split(' ') }
      its(['expires_in_seconds']) { should be_within(2).of Doorkeeper.configuration.access_token_expires_in }
      its(['application'])        { should eql 'uid' => client_app.uid }
      its(:size)                  { should eq 4 }
    end
  end

  describe 'GET /api/v1/profile' do
    let(:scopes) { 'profile.email' }
    let(:params) { nil }
    subject { get '/api/v1/profile', params, header }

    context 'when app does not specify required scopes' do
      let(:scopes) { '' }

      it 'should return an error and message' do
        expect(subject.status).to eq 403
        parsed_json = JSON.parse(subject.body)
        expect(parsed_json['message']).to eq 'Forbidden'
      end

      it 'does not create an user action record' do
        expect { subject }.to_not change(UserAction.api_access.where(record_type: 'Profile'), :count)
      end
    end

    context 'when app has limited scope' do
      let(:scopes) { 'profile.first_name profile.last_name' }

      it 'should return profile limited to requested scopes' do
        expect(subject.status).to eq 200
        parsed_json = JSON.parse(subject.body)
        expect(parsed_json).to be
        expect(parsed_json['first_name']).to eq 'Joan'
        expect(parsed_json).to_not include('email')
      end

      it 'creates an user action record' do
        expect { subject }.to change(UserAction.api_access.where(record_type: 'Profile'), :count).by(1)
      end
    end

    context 'when the user queried exists' do
      context 'when the schema parameter is set' do
        pending 'need to understand Schema.org requirement' do
          let(:params) { { 'schema' => 'true' } }
          it 'should render the response in a Schema.org hash' do
            expect(subject.status).to eq 200
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json).to_not be_nil
            expect(parsed_json['email']).to eq 'joe@citizen.org'
          end
        end
      end

      it 'creates an user action record' do
        expect { subject }.to change(UserAction.api_access.where(record_type: 'Profile'), :count).by(1)
      end
    end
  end

  describe 'POST /api/v1/notifications' do
    let(:client_app_2) { FactoryGirl.create(:application, name: 'App2') }

    let(:token) { FactoryGirl.create(:access_token, application: client_app_2, resource_owner: user, scopes: 'notifications') }

    subject { post '/api/v1/notifications', params, header }

    context 'when the user has a valid token' do
      context 'when the notification attributes are valid' do
        let(:params) { { notification: { subject: 'Project MyUSA', body: 'This is a test.' } } }
        it 'should create a new notification when the notification info is valid' do
          expect(user.notifications.size).to eq 0
          expect(subject.status).to eq 200
          user.notifications.reload
          expect(user.notifications.size).to eq 1
          expect(user.notifications.first.subject).to eq 'Project MyUSA'
        end

        it 'creates an user action record' do
          expect { subject }.to change(UserAction.api_write.where(record_type: 'Notification'), :count).by(1)
        end
      end

      context 'when the notification attributes are not valid' do
        let(:params) { { notification: { body: 'This is a test.' } } }
        it 'should return an error message' do
          expect(subject.status).to eq 400
          parsed_response = JSON.parse(subject.body)
          expect(parsed_response['message']['subject']).to eq ["can't be blank"]
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_write.where(record_type: 'Notification'), :count)
        end
      end
    end
  end

  describe 'Tasks API' do
    let(:scopes) { 'tasks' }
    subject { get '/api/v1/tasks', nil, header }

    describe 'GET /api/v1/tasks.json' do
      context 'when token is valid' do
        context 'when there are tasks for a user, some of which were created by the app making the request' do
          before do
            @task1 = Task.create!(name: 'Task #1', user_id: user.id, app_id: client_app.id)
            @task1.task_items << TaskItem.create!(name: 'Task item 1 (no url)')
            @task2 = Task.create!(name: 'Task #2', user_id: user.id, app_id: client_app.id + 1)
            @task2.task_items << TaskItem.create!(name: 'Task item 1 (with url)', url: 'http://www.google.com')
          end

          it 'should return the tasks that were created by the calling app' do
            expect(subject.status).to eq 200
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json.size).to eq 1
            expect(parsed_json.first['name']).to eq 'Task #1'
          end

          it 'should return the task and task items' do
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json.first['task_items'].first['name']).to eq 'Task item 1 (no url)'
          end

          it 'creates an user action record' do
            expect { subject }.to change(UserAction.api_access.where(record_type: 'Task'), :count).by(1)
          end
        end
      end

      context 'when the the app does not have the proper scope' do
        let(:scopes) { 'notifications' }

        it 'should return an error message' do
          expect(subject.status).to eq 403
          parsed_json = JSON.parse(subject.body)
          expect(parsed_json['message']).to eq 'Forbidden'
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_access.where(record_type: 'Task'), :count)
        end
      end
    end

    describe 'POST /api/v1/tasks' do
      let(:params) do
        { task: { name: 'New Task',
                  url: "http://wwww.gsa.gov/",
                  task_items_attributes: [ { name: "Item 1", external_id: "abc", url: "http://www.gsa.gov/" } ]
                }
        }
      end

      subject { post '/api/v1/tasks', params, header }

      context 'when the caller has a valid token' do
        context 'when the appropriate parameters are specified' do
          it 'should create a new task for the user' do
            expect(subject.status).to eq 200
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json).to_not be_nil
            expect(parsed_json['name']).to eq 'New Task'
            expect(parsed_json['url']).to eq "http://wwww.gsa.gov/"
            expect(Task.where(name: 'New Task', url: "http://wwww.gsa.gov/", user_id: user.id, app_id: client_app.id).count).to eq 1
          end

          it "should create a new task item for the task" do
            expect(subject.status).to eq 200
            parsed_json = JSON.parse(subject.body)

            expect(parsed_json).to_not be_nil
            expect(parsed_json['task_items'].count).to eq 1
            expect(parsed_json['task_items'][0]['name']).to eq 'Item 1'
            expect(parsed_json['task_items'][0]['external_id']).to eq 'abc'
            expect(parsed_json['task_items'][0]['url']).to eq 'http://www.gsa.gov/'

            task = Task.where(name: 'New Task', url: "http://wwww.gsa.gov/", user_id: user.id, app_id: client_app.id).first
            expect(task).to_not be_nil
            expect(task.task_items.count).to eq 1

            item = task.task_items.first
            expect(item.name).to eq "Item 1"
            expect(item.external_id).to eq "abc"
            expect(item).to_not be_completed
          end

          it 'creates an user action record' do
            expect { subject }.to change(UserAction.api_write.where(record_type: 'Task'), :count).by(1)
          end
        end

        context 'when the required parameters are missing' do
          let(:params) { nil }
          it 'should return an error message' do
            expect(subject.status).to eq 400
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json['message']).to eq "can't be blank"
          end

          it 'does not create an user action record' do
            expect { subject }.to_not change(UserAction.api_write.where(record_type: 'Task'), :count)
          end
        end
      end
    end

    describe 'PUT /api/v1/tasks:id.json' do
      subject { put "/api/tasks/#{task.id}", params, header }
      context 'when the caller has a valid token' do
        let!(:task) do
          Task.create!(name: 'Mega task',
                       url: "http://www.gsa.gov/",
                       completed_at: Time.now - 1.day,
                       user_id: user.id,
                       app_id: client_app.id,
                       task_items_attributes: [{ name: 'Task item one', external_id: 'abcdef' }])
        end

        context 'when valid parameters are used' do
          let(:params) do
            { task: { name: 'New Task', url: "http://18f.gsa.gov",
                      task_items_attributes: [{ id: task.task_items.first.id,
                                                name: 'Task item one A' }] } }
          end

          it 'should update the task and task items' do
            expect(subject.status).to eq 200
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json['name']).to eq 'New Task'
            expect(parsed_json['url']).to eq 'http://18f.gsa.gov'
            expect(parsed_json['task_items'].first['name']).to eq 'Task item one A'

            # this shouldn't be changed by the put
            expect(parsed_json['task_items'].first['external_id']).to eq 'abcdef'
          end

          it 'creates an user action record' do
            expect { subject }.to change(UserAction.api_write.where(record_type: 'Task'), :count).by(1)
          end
        end

        context 'when updating a task marked as completed' do
          let(:tasks) do
            Task.create!({
                           name: 'Mega completed task',
                           user_id: user.id,
                           app_id: client_app.id,
                           task_items_attributes: [{ name: 'Task item one' }]
                         }).tap(&:complete!)
          end

          let(:params) do
            { task: { name: 'New Incomplete Task',
                      url: 'http://whitehouse.gov',
                      completed_at: nil,
                      task_items_attributes: [{id: task.task_items.first.id, name: 'Task item one', external_id: 'abc'}]
                    }
            }
          end

          it 'should no longer be marked as complete when specified' do
            expect(subject.status).to eq 200
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json['name']).to eq 'New Incomplete Task'
            expect(parsed_json['url']).to eq 'http://whitehouse.gov'
            expect(parsed_json['task_items'].first['name']).to eq 'Task item one'
            expect(parsed_json['task_items'].first['external_id']).to eq 'abc'
          end

          it 'creates an user action record' do
            expect { subject }.to change(UserAction.api_write.where(record_type: 'Task'), :count).by(1)
          end
        end
        context 'when invalid parameters are used' do
          let(:params) do
            { task: { name: 'New Task',
                      task_items_attributes: [{ id: 'chicken', name: 'updated task item name' }] }}
          end

          it 'should return meaningful errors' do
            expect(subject.status).to eq 404
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json['message']).to_not be_blank
          end

          it 'does not create an user action record' do
            expect { subject }.to_not change(UserAction.api_write.where(record_type: 'Task'), :count)
          end
        end
      end
    end

    describe 'GET /api/v1/tasks/:id.json' do
      let(:task) do
        Task.create! do |t|
          t.name = 'New Task'
          t.url = 'http://www.gsa.gov'
          t.user_id = user.id
          t.app_id = client_app.id
          t.task_items = [
            TaskItem.new(name: "Task Item #1"),
            TaskItem.new(name: "Task Item #2", url: 'http://valid_url.com')
          ]
        end
      end
      subject { get "/api/tasks/#{task.id}", nil, header }

      context 'when the token is valid' do
        it 'should retrieve the task' do
          expect(subject.status).to eq 200
          parsed_json = JSON.parse(subject.body)
          expect(parsed_json).to_not be_nil
          expect(parsed_json['name']).to eq 'New Task'
          expect(parsed_json['url']).to eq 'http://www.gsa.gov'
          expect(parsed_json['task_items'].first['name']).to eq "Task Item #1"
          expect(parsed_json['task_items'].last['url']).to eq 'http://valid_url.com'
        end

        it 'creates an user action record' do
          expect { subject }.to change(UserAction.api_access.where(record_type: 'Task'), :count).by(1)
        end
      end

      context "when the task exists but belongs to another user" do
        before { task.update_attribute(:user_id, user.id + 1) }

        it "should return a 403 response" do
          expect(subject.status).to eq(403)
        end
      end

      context "when the task does not exist" do
        subject { get "/api/tasks/#{task.id + 10_000}", nil, header }
        it "should return a 404 error" do
          expect(subject.status).to eq(404)
        end
      end
    end

    describe 'DELETE api/v1/tasks/:id' do
      let!(:task) do
        Task.create! do |t|
          t.name = 'New Task'
          t.url = 'http://www.gsa.gov'
          t.user_id = user.id
          t.app_id = client_app.id
          t.task_items = [
            TaskItem.new(name: "Task Item #1"),
            TaskItem.new(name: "Task Item #2", url: 'http://valid_url.com')
          ]
        end
      end

      context "when the token is valid" do
        subject { delete "/api/tasks/#{task.id}", nil, header }

        it "should return a status of 200" do
          expect(subject.status).to eq(200)
        end

        it "should delete the task" do
          expect { subject }.to change(Task.where(id: task.id), :count).by(-1)
        end

        it "should delete any associated task_items" do
          expect { subject }.to change(Task.where(id: task.id), :count).by(-1)
        end

        it 'creates an user action record' do
          expect { subject }.to change(UserAction.api_destroy.where(record_type: 'Task'), :count).by(1)
        end
      end

      context "when the task belongs to a different user" do
        before { task.update_attribute(:user_id, user.id + 1) }

        before { @response = delete "/api/tasks/#{task.id}", nil, header }

        it "should return a status of 403" do
          expect(@response.status).to eq(403)
        end

        it "should not delete the Task" do
          expect(Task.where(id: task.id).count).to eq(1)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_destroy.where(record_type: 'Task'), :count)
        end
      end

      context "when the token is invalid" do
        before { @response = delete "/api/v1/tasks/#{task.id}", nil, empty_header }

        it "should return a 401 status" do
          expect(@response.status).to eq(401)
        end

        it "should not delete anything" do
          expect(Task.where(id: task.id).count).to eq(1)
          expect(TaskItem.where(task_id: task.id).count).to eq(2)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_write.where(record_type: 'Task'), :count)
        end
      end
    end
  end

  describe "Task Items API" do
    let(:scopes) { 'tasks' }

    describe "POST /api/v1/tasks/:id/task_items" do
      let!(:task) do
        Task.create! do |t|
          t.name = 'New Task'
          t.url = 'http://www.gsa.gov'
          t.user_id = user.id
          t.app_id = client_app.id
        end
      end

      let(:params) { { task_item: { name: 'Task item one', external_id: 'abc', url: "http://gsa.gov/" } } }

      context "when the token is valid" do
        subject { post "/api/v1/tasks/#{task.id}/task_items", params, header }

        it "should return a 200 status" do
          expect(subject.status).to eq(200)
        end

        it "should return the JSON of the task" do
          parsed_json = JSON.parse(subject.body)
          expect(parsed_json['name']).to eq(params[:task_item][:name])
          expect(parsed_json['url']).to eq(params[:task_item][:url])
          expect(parsed_json['external_id']).to eq(params[:task_item][:external_id])
          expect(parsed_json['task_id']).to eq(task.id)
        end

        it "should create a new task item associated with that task" do
          expect { subject }.to change(TaskItem, :count).by(1)
        end

        it 'creates an user action record' do
          expect { subject }.to change(UserAction.api_write.where(record_type: 'TaskItem'), :count).by(1)
        end
      end

      context "when the task belongs to another user" do
        before { task.update_attribute(:user_id, task.user_id + 10) }
        subject { post "/api/v1/tasks/#{task.id}/task_items", params, header }

        it "should return a 403 status" do
          expect(subject.status).to eq(403)
        end

        it "should not create a task item" do
          expect { subject }.to_not change(TaskItem, :count)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_write.where(record_type: 'TaskItem'), :count)
        end
      end

      context "when the token is not valid" do
        subject { post "/api/v1/tasks/#{task.id}/task_items", params, empty_header }

        it "should return a HTTP 401 status" do
          expect(subject.status).to eq(401)
        end

        it "should create nothing" do
          expect { subject }.to_not change(TaskItem, :count)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_write.where(record_type: 'Task'), :count)
        end
      end
    end

    describe "GET /api/v1/tasks/:id/task_items" do
      let(:task) do
        Task.create! do |t|
          t.name = 'New Task'
          t.url = 'http://www.gsa.gov'
          t.user_id = user.id
          t.app_id = client_app.id
          t.task_items = [
            TaskItem.new(name: "Task Item #1", "external_id": "abcdef"),
            TaskItem.new(name: "Task Item #2", url: 'http://valid_url.com')
          ]
        end
      end

      subject { get "/api/v1/tasks/#{task.id}/task_items", nil, header }

      context "when the token is valid" do
        it "should return a HTTP 200 status" do
          expect(subject.status).to eq(200)
        end

        it "should return all the task_items associated with that task in an array" do
          expect(subject.status).to eq(200)
          parsed_json = JSON.parse(subject.body)
          expect(parsed_json.length).to eq(2)
          expect(parsed_json.first["name"]).to eq("Task Item #1")
          expect(parsed_json.last["name"]).to eq("Task Item #2")
        end

        it 'creates an user action record' do
          expect { subject }.to change(UserAction.api_access.where(record_type: 'TaskItem'), :count).by(2)
        end
      end

      context "when the task does not exist" do
        before { task.delete }

        it "should return a 404 HTTP status" do
          expect(subject.status).to eq(404)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_access.where(record_type: 'TaskItem'), :count)
        end
      end

      context "when the task belongs to someone else" do
        before { task.update_attribute(:user_id, task.user_id + 10) }

        it "should return a 403 HTTP status" do
          expect(subject.status).to eq(403)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_access.where(record_type: 'TaskItem'), :count)
        end
      end

      context "when the token is invalid" do
        subject { get "/api/v1/tasks/#{task.id}/task_items", nil, empty_header }

        it "should return a 401 HTTP status" do
          expect(subject.status).to eq(401)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_access.where(record_type: 'TaskItem'), :count)
        end
      end
    end

    describe "PUT /api/v1/tasks/:id/task_items/:item_id" do
      let!(:task) do
        Task.create! do |t|
          t.name = 'New Task'
          t.url = 'http://www.gsa.gov'
          t.user_id = user.id
          t.app_id = client_app.id
          t.task_items = [
            TaskItem.new(name: "Task Item #1", "external_id": "abcdef"),
            TaskItem.new(name: "Task Item #2", url: 'http://valid_url.com')
          ]
        end
      end

      let!(:task_item) { task.task_items.first }
      let(:params) { { task_item: { name: "Task Item Changed", "complete": true } } }

      subject { put "/api/v1/tasks/#{task.id}/task_items/#{task_item.id}", params, header }

      context "when the token is valid" do
        it "should return a HTTP 200 status code" do
          expect(subject.status).to eq(200)
        end

        it "should return JSON representing the new task item" do
          parsed_json = JSON.parse(subject.body)
          expect(parsed_json["name"]).to eq(params[:task_item][:name])
          expect(parsed_json["external_id"]).to eq(task_item.external_id)
          expect(parsed_json["completed_at"]).to_not be_blank
        end

        it "should update the task item with specified fields" do
          expect { subject }.to_not change(TaskItem, :count)
          t = TaskItem.find(task_item.id)
          expect(t.name).to eq(params[:task_item][:name])
          expect(t.completed_at).to_not be_nil
          expect(t).to be_completed
        end

        it "should not change fields that are not specified" do
          expect { subject }.to_not change(TaskItem, :count)
          task_item2 = TaskItem.find(task_item.id)
          expect(task_item2.external_id).to eq(task_item.external_id)
          expect(task_item2.url).to eq(task_item.url)
        end

        it 'creates an user action record' do
          expect { subject }.to change(UserAction.api_write.where(record_type: 'TaskItem'), :count).by(1)
        end
      end

      context "when the task does not exist" do
        before { task.destroy }

        it "should return a 404 status" do
          expect(subject.status).to eq(404)
        end

        it "should not create any task items" do
          expect { subject }.to_not change(TaskItem, :count)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_write.where(record_type: 'TaskItem'), :count)
        end
      end

      context "when the task belongs to someone else" do
        before { task.update_attribute(:user_id, task.user_id + 10) }

        it "should return a 403 status" do
          expect(subject.status).to eq(403)
        end

        it "should not create any task items" do
          expect { subject }.to_not change(TaskItem, :count)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_write.where(record_type: 'TaskItem'), :count)
        end
      end

      context "when the token is invalid" do
        subject { put "/api/v1/tasks/#{task.id}/task_items/#{task_item.id}", params, empty_header }

        it "should return a HTTP 401 status" do
          expect(subject.status).to eq(401)
        end

        it "should not update the task item" do
          subject
          task_item2 = TaskItem.find(task_item.id)
          expect(task_item2).to eq(task_item)
        end

        it 'does not create an user action record' do
          expect { subject }.to_not change(UserAction.api_write.where(record_type: 'TaskItem'), :count)
        end
      end
    end

    describe "DELETE /api/v1/tasks/:id/task_items/:item_id" do
      let(:task) do
        Task.create! do |t|
          t.name = 'New Task'
          t.url = 'http://www.gsa.gov'
          t.user_id = user.id
          t.app_id = client_app.id
          t.task_items = [
            TaskItem.new(name: "Task Item #1", "external_id": "abcdef")
          ]
        end
        let(:task_item) { task.task_items.first }

        subject { delete "/api/v1/tasks/#{task.id}/task_items/#{task_item.id}", nil, header }

        context "when the token is valid" do
          it "should return a HTTP 200 status code" do
            expect(subject.status).to eq(200)
          end

          it "should return a JSON representation of the task item" do
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json["name"]).to eq(task_item["name"])
            expect(parsed_json["external_id"]).to eq(task_item["abcdef"])
          end

          it "should delete the task_item" do
            expect { subject }.to change(TaskItem, :count).by(-1)
          end

          it 'creates an user action record' do
            expect { subject }.to change(UserAction.api_destroy.where(record_type: 'TaskItem'), :count).by(1)
          end
        end

        context "when the task does not exist" do
          before { task.destroy }

          it "should return a 404 status" do
            expect(subject.status).to eq(404)
          end

          it 'does not create an user action record' do
            expect { subject }.to_not change(UserAction.api_destroy.where(record_type: 'TaskItem'), :count)
          end
        end

        context "when the task_item does not exist" do
          before { task_item.destroy }

          it "should return a 404 status" do
            expect(subject.status).to eq(404)
          end

          it 'does not create an user action record' do
            expect { subject }.to_not change(UserAction.api_destroy.where(record_type: 'TaskItem'), :count)
          end
        end

        context "when the task belongs to another user" do
          before { task.update_attribute(:user_id, task.user_id + 10) }

          it "should return a 403 status" do
            expect(subject.status).to eq(403)
          end

          it "should not delete the task_item" do
            expect { subject }.to_not change(TaskItem, :count)
          end

          it 'does not create an user action record' do
            expect { subject }.to_not change(UserAction.api_destroy.where(record_type: 'TaskItem'), :count)
          end
        end

        context "when the token is invalid" do
          subject { delete "/api/v1/tasks/#{task.id}/task_items/#{task_item.id}", nil, empty_header }

          it "should return a HTTP 401 error" do
            expect(subject.status).to eq(401)
          end

          it "should not delete the task" do
            expect { subject }.to_not change(TaskItem, :count)
          end

          it 'does not create an user action record' do
            expect { subject }.to_not change(UserAction.api_destroy.where(record_type: 'TaskItem'), :count)
          end
        end
      end
    end
  end

  describe 'Authorized Scopes API' do
    pending 'need to figure out how to query for scopes with Doorkeeper' do
      describe 'GET /api/v1/authorized_scopes' do
        context 'when a valid token is provided' do
          let(:scopes) do
            OauthScope.top_level_scopes.where(scope_type: 'user') <<
              OauthScope.find_by_scope_name('profile.first_name') <<
              OauthScope.find_by_scope_name('profile.last_name')
          end

          let(:scopes_selected) do
            OauthScope.top_level_scopes.where(scope_type: 'user') <<
              OauthScope.find_by_scope_name('profile.last_name')
          end

          let(:scope_app) do
            App.create(name: 'app_limited',
                       redirect_uri: 'http://localhost/',
                       oauth_scopes: scopes)
          end
          let(:token) { build_access_token(scope_app, scopes_selected.map(&:scope_name).join(' ')) }

          it 'returns the list of scopes approved by user' do
            response = get '/api/v1/authorized_scopes', nil, header

            parsed_json = JSON.parse(response.body)
            expected_scopes = scopes_selected.map(&:scope_name)
            expect(parsed_json.sort).to eql expected_scopes.sort
          end
        end
      end
    end
  end
end
