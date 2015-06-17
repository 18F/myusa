require 'spec_helper'

describe Api::V1 do
  let(:client_app) { FactoryGirl.create(:application) }
  let(:user) { FactoryGirl.create(:user, :with_profile) }
  let(:scopes) { '' }
  let(:token) { FactoryGirl.create(:access_token, application: client_app, resource_owner: user, scopes: scopes) }
  let(:header) { {'HTTP_AUTHORIZATION' => "Bearer #{token.token}"} }

  describe 'Legacy tokens path' do
    let(:grant) {
      FactoryGirl.create(:access_grant,
        application: client_app,
        redirect_uri: client_app.redirect_uri,
        resource_owner: user
      )
    }
    let(:params) do
      {
        client_id: client_app.uid,
        client_secret: client_app.secret,
        code: grant.token,
        grant_type: 'authorization_code',
        redirect_uri: client_app.redirect_uri
      }
    end

    subject { post  '/oauth/authorize', params }
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
      its(['application'])        { should eql 'uid'=>client_app.uid }
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
          let(:params) { {'schema' => 'true'} }
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
        let(:params) { {notification: {subject: 'Project MyUSA', body: 'This is a test.'}} }
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
        let(:params) { {notification: {body: 'This is a test.'} } }
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
            @task1 = Task.create!({name: 'Task #1', user_id: user.id, app_id: client_app.id})
            @task1.task_items << TaskItem.create!(name: 'Task item 1 (no url)')
            @task2 = Task.create!({name: 'Task #2', user_id: user.id, app_id: client_app.id + 1})
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
      let(:params) { {task: { name: 'New Task', url: "http://wwww.gsa.gov/" }} }
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
          Task.create!({
            name: 'Mega task',
            url: "http://www.gsa.gov/",
            completed_at: Time.now-1.day,
            user_id: user.id,
            app_id: client_app.id,
            task_items_attributes: [{ name: 'Task item one', external_id: 'abcdef' }]
          })
        end

        context 'when valid parameters are used' do
          let(:params) { { task: { name: 'New Task', url: "http://18f.gsa.gov", task_items_attributes: [{ id: task.task_items.first.id, name: 'Task item one A' }] }} }

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
            }).tap {|t| t.complete! }
          end

          let(:params) { {task: { name: 'New Incomplete Task', url: 'http://whitehouse.gov', completed_at: nil, task_items_attributes: [{ id: task.task_items.first.id, name: 'Task item one', external_id: 'abc' }] }} }

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
          let(:params) { {task: { name: 'New Task' , task_items_attributes: [{ id: 'chicken', name: 'updated task item name' }] }} }

          it 'should return meaningful errors' do
            expect(subject.status).to eq 422
            parsed_json = JSON.parse(subject.body)
            expect(parsed_json['message']).to eq 'Invalid parameters. Check your values and try again.'
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
