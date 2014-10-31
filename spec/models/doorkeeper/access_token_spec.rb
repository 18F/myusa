require 'rails_helper'

describe Doorkeeper::AccessToken do
  let(:user) { FactoryGirl.create(:user) }
  let(:client_app) { FactoryGirl.create(:application)}

  describe "create" do
    subject { -> { FactoryGirl.create(:access_token, resource_owner: user, application: client_app) } }

    context 'when authorization does not exist' do
      it 'creates a new authorization' do
        is_expected.to change(Authorization.where(user_id: user.id, application_id: client_app.id), :count).by(1)
      end
    end

    context 'when authorization already exists' do
      before :each do
        FactoryGirl.create(:access_token, resource_owner: user, application: client_app)
      end
      
      it 'does not create a new authorization' do
        is_expected.to_not change(Authorization.where(user_id: user.id, application_id: client_app.id), :count)
      end
    end

    it 'creates an audit record' do
      is_expected.to change(UserAction.where(record_type: Doorkeeper::AccessToken, action: 'issue'), :count).by(1)
    end
  end

  describe "#revoke" do
    let(:token) { FactoryGirl.create(:access_token) }

    it 'creates an audit record' do
      expect { token.revoke }.to change(UserAction.where(record_type: Doorkeeper::AccessToken, action: 'revoke'), :count).by(1)
    end
  end
end
