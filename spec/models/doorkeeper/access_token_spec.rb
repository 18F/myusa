require 'rails_helper'

describe Doorkeeper::AccessToken do
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { FactoryGirl.build(:access_token) }

  describe "create" do
    it 'creates an audit record' do
      expect { token.save! }.to change {
        UserAction.where(record_type: Doorkeeper::AccessToken).count
      }.by(1)
    end
  end

end
