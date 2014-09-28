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
    end
  end

  describe '#update' do
    let(:app) { FactoryGirl.create(:application, owner: user) }

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

  end
end
