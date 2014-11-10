require 'rails_helper'

describe Doorkeeper::AccessToken do
  let(:authorization) { FactoryGirl.create(:authorization) }

  describe "#revoke" do
    before :each do
      @token1 = FactoryGirl.create(:access_token, authorization: authorization)
      @token2 = FactoryGirl.create(:access_token, authorization: authorization)
      @token2 = FactoryGirl.create(:access_token, authorization: authorization)
    end

    it 'revokes all tokens' do
      authorization.revoke

      expect(authorization.oauth_tokens).to all be_revoked
    end
  end
end
