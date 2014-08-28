require 'rails_helper'

describe Doorkeeper::AccessToken do
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { FactoryGirl.build(:access_token, resource_owner: user) }

  describe "create" do
    it 'creates an audit record' do
      expect { token.save! }.to change { user.user_actions.count }.by(1)

      expect(user.user_actions.last.user).to eq(user)
      expect(user.user_actions.last.record).to eq(token)
      expect(user.user_actions.last.action).to eq('create')
    end
  end

end
