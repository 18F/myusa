require 'rails_helper'

describe Doorkeeper::AccessToken do
  let(:user) { FactoryGirl.create(:user) }

  describe "create" do
    let(:token) { FactoryGirl.build(:access_token) }

    it 'creates an audit record' do
      expect { token.save! }.to change {
        UserAction.where(record_type: Doorkeeper::AccessToken, action: 'issue').count
      }.by(1)
    end
  end

  describe "#revoke" do
    let(:token) { FactoryGirl.create(:access_token) }

    it 'creates an audit record' do
      expect { token.revoke }.to change {
        UserAction.where(record_type: Doorkeeper::AccessToken, action: 'revoke').count
      }.by(1)
    end
  end
end
