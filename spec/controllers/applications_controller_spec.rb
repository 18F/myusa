require 'rails_helper'

describe ApplicationsController do
  let(:user) { FactoryGirl.create(:user) }

  describe '#create' do
    subject { -> { post :create, application: application_params } }

    before :each do
      sign_in user
    end

    context 'with valid params' do
      let(:application_params) do
        {
          name: 'Test App',
          redirect_uri: 'http://www.example.com/callback',
          scopes: 'profile.email profile.last_name profile.first_name tasks'
        }
      end

      it 'saves' do
        is_expected.to change { Doorkeeper::Application.count }.by(1)
      end

      it 'ownership is set' do
        is_expected.to change { user.oauth_applications.count }.by(1)
        expect(user).to have_role(:owner, user.oauth_applications.last)
      end

      it 'should create the application and scopes' do
        subject.call
        app = Doorkeeper::Application.where(name: 'Test App').first 

        expect(app).to_not be_nil
        expect(app.redirect_uri).to eq('http://www.example.com/callback')
        expect(app.scopes.sort.join(' ')).to eq('profile.email profile.first_name profile.last_name tasks') 
        expect(app.application_scopes.length).to eq(4)
      end
    end
  end

  describe '#show' do
    let(:user) { FactoryGirl.create(:user) }
    let(:owner) { user }

    let(:app) { FactoryGirl.create(:application, name: 'My App', owner: owner) }

    subject { -> { get :show, id: app.id } }

    before :each do
      sign_in user
      sign_in :two_factor, user
    end

    context 'current user is owner' do
      it 'has 200 status code' do
        subject.call
        expect(response.status).to eq(200)
      end
    end

    context 'current user is admin' do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:owner) { FactoryGirl.create(:user) }

      it 'has 200 status code' do
        subject.call
        expect(response.status).to eq(200)
      end

      it 'creates a UserAction record' do
        is_expected.to change(UserAction.admin_action, :count).by(1)
      end
    end

    context 'current user is neither owner nor admin' do
      let(:owner) { FactoryGirl.create(:user) }

      it 'raises SimpleRole::AccessDenied' do
        is_expected.to raise_error(SimpleRole::AccessDenied)
      end
    end
  end

  describe '#update' do
    let(:owner) { user }
    let(:app) { FactoryGirl.create(:application, name: 'My App', owner: owner, public: false) }
    let(:application_params) { { name: 'Best App Ever' } }

    subject { -> { put :update, id: app.id, application: application_params } }

    before :each do
      sign_in :user, user
      sign_in :two_factor, user
    end

    context 'current user is owner' do
      it 'updates app name' do
        is_expected.to change { app.reload.name }.to('Best App Ever')
      end

      context 'user attempts to set app to public' do
        let(:application_params) { { public: true } }

        it 'does not set public status' do
          is_expected.to_not change { app.reload.public }
        end
      end
    end

    context 'current user is admin' do
      let(:owner) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:admin_user) }

      it 'updates app name' do
        is_expected.to change { app.reload.name }.to('Best App Ever')
      end

      context 'user attempts to set app to public' do
        let(:application_params) { { public: true } }

        it 'sets public status' do
          is_expected.to change { app.reload.public }.from(false).to(true)
        end
      end

    end

    context 'current user is neither owner nor admin' do
      let(:owner) { FactoryGirl.create(:user) }

      it 'raises SimpleRole::AccessDenied' do
        is_expected.to raise_error(SimpleRole::AccessDenied)
      end

      it 'does not update' do
        expect { subject.call rescue nil }.to_not change { app.reload.name }
      end
    end
  end
end
