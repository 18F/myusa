require 'spec_helper'

describe Api::V1 do
  def build_access_token(a, scopes=[])
    Doorkeeper::AccessToken.create!(
      application_id: a.id,
      resource_owner_id: user.id,
      scopes: scopes.join(' '),
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: false
    ).token
  end

  let(:client_app) { FactoryGirl.create(:application) }
  let(:user) { create_confirmed_user_with_profile(is_student: nil, is_retired: false) }

  describe 'Token validity check' do
    subject { get '/api/v1/profile', nil, { 'HTTP_AUTHORIZATION' => "Bearer #{token}" } }
    context 'with a valid token' do
      let(:token)  { build_access_token(client_app, ['profile.email']) }
      its(:status) { should eq 200 }
    end
    context 'with an invalid token' do
      let(:token)  { 'bad token! No cookie!' }
      its(:status) { should eq 401 }
      it 'should include an error message' do
        expect(JSON.parse(subject.body)['message']).to eql 'Not Authorized'
      end
    end
  end

  describe 'GET /api/v1/tokeninfo' do
    let(:path)   { '/api/v1/tokeninfo' }
    let(:scopes) { ['profile.first_name', 'profile.last_name'] }
    let(:token)  { build_access_token(client_app, scopes) }
    describe "response status" do
      subject { get path, nil, { 'HTTP_AUTHORIZATION' => "Bearer #{token}" } }
      its(:status) { should eq 200 }
    end
    describe "response body" do
      subject { JSON.parse(get(path, nil, 'HTTP_AUTHORIZATION' => "Bearer #{token}").body) }
      its(['resource_owner_id'])  { should eq user.id }
      its(['scopes'])             { should eq scopes }
      its(['expires_in_seconds']) { should be_within(2).of Doorkeeper.configuration.access_token_expires_in }
      its(['application'])        { should eql 'uid'=>client_app.uid }
      its(:size)                  { should eq 4 }
    end
  end

  describe 'GET /api/v1/profile' do
    let(:token) { build_access_token(client_app) }

    context 'when app does not specify required scopes' do
      it 'should return an error and message' do
        response = get '/api/v1/profile', nil, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
        expect(response.status).to eq 403
        parsed_json = JSON.parse(response.body)
        expect(parsed_json['message']).to eq 'Forbidden'
      end
    end

    context 'when app has limited scope' do
      let(:token) { build_access_token(client_app, ['profile.first_name', 'profile.last_name']) }

      it 'should return profile limited to requested scopes' do
        response = get '/api/v1/profile', nil, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
        expect(response.status).to eq 200
        parsed_json = JSON.parse(response.body)
        expect(parsed_json).to be
        expect(parsed_json['first_name']).to eq 'Joe'
        expect(parsed_json).to_not include('email')
      end
    end

    context 'when the user queried exists' do
      let(:token) { build_access_token(client_app, ['profile']) }
      context 'when the schema parameter is set' do
        pending 'need to understand Schema.org requirement' do
          it 'should render the response in a Schema.org hash' do
            response = get '/api/v1/profile', {'schema' => 'true'}, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
            expect(response.status).to eq 200
            parsed_json = JSON.parse(response.body)
            puts response.body
            expect(parsed_json).to_not be_nil
            expect(parsed_json['email']).to eq 'joe@citizen.org'
          end
        end
      end
    end
  end

  describe 'POST /api/v1/notifications' do
    let(:client_app_2) { FactoryGirl.create(:application, name: 'App2') }
    # Doorkeeper::Application.create(name: 'App2', redirect_uri: 'http://localhost/') }
    let(:other_user) { create_confirmed_user_with_profile(email: 'jane@citizen.org', first_name: 'Jane') }

    let(:token) { build_access_token(client_app_2, ['notifications']) }

    before do
      # app2.oauth_scopes << OauthScope.top_level_scopes
      1.upto(14) do |index|
        @notification = Notification.create!({subject: "Notification ##{index}", received_at: Time.now - 1.hour, body: "This is notification ##{index}.", user_id: user.id, app_id: client_app_2.id})
      end
      @other_user_notification = Notification.create!({subject: 'Other User Notification', received_at: Time.now - 1.hour, body: 'This is a notification for a different user.', user_id: other_user.id, app_id: client_app.id})
      @other_app_notification = Notification.create!({subject: 'Other App Notification', received_at: Time.now - 1.hour, body: 'This is a notification for a different app.', user_id: user.id, app_id: client_app_2.id})
      user.notifications.each{ |n| n.destroy(:force) }
      user.notifications.reload
    end

    context 'when the user has a valid token' do
      context 'when the notification attributes are valid' do
        it 'should create a new notification when the notification info is valid' do
          expect(user.notifications.size).to eq 0
          response = post '/api/v1/notifications', {notification: {subject: 'Project MyUSA', body: 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
          expect(response.status).to eq 200
          user.notifications.reload
          expect(user.notifications.size).to eq 1
          expect(user.notifications.first.subject).to eq 'Project MyUSA'
        end
      end

      context 'when the notification attributes are not valid' do
        it 'should return an error message' do
          response = post '/api/v1/notifications', {notification: {body: 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
          expect(response.status).to eq 400
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['message']['subject']).to eq ["can't be blank"]
        end
      end
    end
  end

  describe 'Tasks API' do

    let(:token) { build_access_token(client_app, ['tasks']) }

    describe 'GET /api/v1/tasks.json' do
      context 'when token is valid' do
        context 'when there are tasks for a user, some of which were created by the app making the request' do
          before do
            @task1 = Task.create!({name: 'Task #1', user_id: user.id, app_id: client_app.id})
            @task1.task_items << TaskItem.create!(name: 'Task item 1 (no url)')
            @task2 = Task.create!({name: 'Task #2', user_id: user.id, app_id: client_app.id + 1})
            @task2.task_items << TaskItem.create!(name: 'Task item 1 (with url)', url: 'http://www.google.com')
          end

          it 'should return the tasks that were created by the calling app' do
            response = get '/api/v1/tasks', nil, {'HTTP_AUTHORIZATION' => "Bearer #{token}" }
            expect(response.status).to eq 200
            parsed_json = JSON.parse(response.body)
            expect(parsed_json.size).to eq 1
            expect(parsed_json.first['name']).to eq 'Task #1'
          end

          it 'should return the task and task items' do
            response = get '/api/v1/tasks', nil, {'HTTP_AUTHORIZATION' => "Bearer #{token}" }
            parsed_json = JSON.parse(response.body)
            expect(parsed_json.first['task_items'].first['name']).to eq 'Task item 1 (no url)'
          end
        end
      end

      context 'when the the app does not have the proper scope' do
        let(:token) { build_access_token(client_app, ['notifications']) }

        it 'should return an error message' do
          response = get '/api/v1/tasks', nil, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
          expect(response.status).to eq 403
          parsed_json = JSON.parse(response.body)
          expect(parsed_json['message']).to eq 'Forbidden'
        end
      end
    end

    describe 'POST /api/v1/tasks' do
      context 'when the caller has a valid token' do
        context 'when the appropriate parameters are specified' do
          it 'should create a new task for the user' do
            response = post '/api/v1/tasks', {task: { name: 'New Task' }}, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
            expect(response.status).to eq 200
            parsed_json = JSON.parse(response.body)
            expect(parsed_json).to_not be_nil
            expect(parsed_json['name']).to eq 'New Task'
            expect(Task.where(name: 'New Task', user_id: user.id, app_id: client_app.id).count).to eq 1
          end
        end

        context 'when the required parameters are missing' do
          it 'should return an error message' do
            response = post '/api/v1/tasks', nil, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
            expect(response.status).to eq 400
            parsed_json = JSON.parse(response.body)
            expect(parsed_json['message']).to eq "can't be blank"
          end
        end
      end
    end

    describe 'PUT /api/v1/tasks:id.json' do
      context 'when the caller has a valid token' do
        let(:task) do
          Task.create!({
            name: 'Mega task',
            completed_at: Time.now-1.day,
            user_id: user.id,
            app_id: client_app.id,
            task_items_attributes: [{ name: 'Task item one' }]
          })
        end

        context 'when valid parameters are used' do
          it 'should update the task and task items' do
            response = put "/api/tasks/#{task.id}", {task: { name: 'New Task' , task_items_attributes: [{ id: task.task_items.first.id, name: 'Task item one' }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
            expect(response.status).to eq 200
            parsed_json = JSON.parse(response.body)
            expect(parsed_json['name']).to eq 'New Task'
            expect(parsed_json['task_items'].first['name']).to eq 'Task item one'
          end
        end

        context 'when updating a task marked as completed' do
          let(:tasks) do
            Task.create!({
              name: 'Mega completed task',
              user_id: user.id,
              app_id: client_app.id,
              task_items_attributes: [{ name: 'Task item one' }]
            }).tap {|t| t.complete! }
          end

          it 'should no longer be marked as complete when specified' do
            response = put "/api/tasks/#{task.id}", {task: { name: 'New Incomplete Task', completed_at: nil, task_items_attributes: [{ id: task.task_items.first.id, name: 'Task item one' }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
            expect(response.status).to eq 200
            parsed_json = JSON.parse(response.body)
            expect(parsed_json['name']).to eq 'New Incomplete Task'
            expect(parsed_json['task_items'].first['name']).to eq 'Task item one'
          end
        end
        context 'when invalid parameters are used' do
          it 'should return meaningful errors' do
            response = put "/api/tasks/#{task.id}", {task: { name: 'New Task' , task_items_attributes: [{ id: 'chicken', name: 'updated task item name' }] }}, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
            expect(response.status).to eq 422
            parsed_json = JSON.parse(response.body)
            expect(parsed_json['message']).to eq 'Invalid parameters. Check your values and try again.'
          end
        end
      end
    end

    describe 'GET /api/v1/tasks/:id.json' do
      let(:task) do
        Task.create! do |t|
          t.name = 'New Task'
          t.user_id = user.id
          t.app_id = client_app.id
          t.task_items = [
            TaskItem.new(name: "Task Item #1"),
            TaskItem.new(name: "Task Item #2", url: 'http://valid_url.com')
          ]
        end
      end

      context 'when the token is valid' do
        it 'should retrieve the task' do
          response = get "/api/tasks/#{task.id}", nil, {'HTTP_AUTHORIZATION' => "Bearer #{token}"}
          expect(response.status).to eq 200
          parsed_json = JSON.parse(response.body)
          expect(parsed_json).to_not be_nil
          expect(parsed_json['name']).to eq 'New Task'
          expect(parsed_json['task_items'].first['name']).to eq "Task Item #1"
          expect(parsed_json['task_items'].last['url']).to eq 'http://valid_url.com'
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
            response = get '/api/v1/authorized_scopes', nil,
                           {'HTTP_AUTHORIZATION' => "Bearer #{token}"}

            parsed_json = JSON.parse(response.body)
            expected_scopes = scopes_selected.map(&:scope_name)
            expect(parsed_json.sort).to eql expected_scopes.sort
          end
        end
      end
    end
  end
end
