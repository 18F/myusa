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
          owner_emails: user.email,
          scopes: 'profile.email'
        }
      end

      it 'saves' do
        is_expected.to change { Doorkeeper::Application.count }.by(1)
      end
    end

    context 'when current user is removed from owner_emails' do
      let(:application_params) do
        {
          name: 'Test App',
          redirect_uri: 'http://www.example.com/callback',
          owner_emails: '',
          scopes: 'profile.email'
        }
      end

      it 'does not save' do
        is_expected.to_not change { Doorkeeper::Application.count }
      end
    end
  end

  describe '#update' do
    let(:app) { FactoryGirl.create(:application, owner_emails: user.email) }

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

    context 'when current user is removed from owner_emails' do
      let(:application_params) { { owner_emails: '' } }
      it 'does not update' do
        is_expected.to_not change { app.reload.owner_emails }
      end
    end
  end
end
