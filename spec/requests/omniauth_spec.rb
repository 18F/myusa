require 'spec_helper'

describe 'OmniAuth' do
  let(:email) { 'test@example.gov' }
  let(:omniauth_provider) { :google_oauth2 }
  let(:omniauth_uid) { 12345 }

  let(:omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: omniauth_provider,
      uid: omniauth_uid,
      info: {
        email: email
      }
    )
  end

  before :each do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[omniauth_provider] = omniauth_hash
  end

  shared_examples 'success' do
    it 'creates successful_authentication user action' do
      expect { get '/users/auth/google_oauth2/callback' }.to change(UserAction.successful_authentication.where(data: "{\"authentication_method\":\"google_oauth2\"}"), :count).by(1)
    end
  end

  context 'with existing user' do
    before :each do
      FactoryGirl.create(:user, email: email)
    end

    it 'does not create user' do
      expect { get '/users/auth/google_oauth2/callback' }.to_not change(User, :count)
    end

    include_examples "success"
  end

  context 'without existing user' do
    it 'creates user' do
      expect { get '/users/auth/google_oauth2/callback' }.to change(User, :count).by(1)
    end

    include_examples "success"
  end

  context 'failure' do
    before :each do
      OmniAuth.config.mock_auth[omniauth_provider] = :invalid_credentials
    end

    it 'creates failed_authentication user action' do
      expect { get '/users/auth/google_oauth2/callback' }.to change(UserAction.failed_authentication.where(data: "{\"authentication_method\":\"google_oauth2\"}"), :count).by(1)
    end
  end
end
