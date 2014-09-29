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
          scopes: 'profile.email'
        }
      end

      it 'saves' do
        is_expected.to change { Doorkeeper::Application.count }.by(1)
      end

      it 'ownership is set' do
        is_expected.to change { user.oauth_applications.count }.by(1)
      end

    end
  end

  describe '#update' do
    let(:app) { FactoryGirl.create(:application, name: 'My App', owner: user) }

    subject { -> { put :update, id: app.id, application: application_params } }

    before :each do
      sign_in user
    end

    context 'with valid params' do
      let(:application_params) { { name: 'Best App Ever' } }

      it 'updates' do
        is_expected.to change { app.reload.name }.to('Best App Ever')
      end
    end

    context 'if owner is not current user' do
      let(:somebody_else) { FactoryGirl.create(:user) }
      let(:app) { FactoryGirl.create(:application, owner: somebody_else) }
      let(:application_params) { { name: 'My App Now!' } }

      it 'raises 404' do
        is_expected.to raise_error(ActiveRecord::RecordNotFound) #change { app.reload.name }
      end

      it 'does not update' do
        expect { subject.call rescue nil }.to_not change { app.reload.name }
      end
    end
  end
end
