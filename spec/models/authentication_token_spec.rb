require 'rails_helper'

describe AuthenticationToken, type: :model do
  let(:user) { FactoryGirl.create(:user) }

  describe '#generate' do
    it 'generates a token' do
      token = AuthenticationToken.generate(user: user)
      expect(token.token).to be
    end

    context 'multiple tokens' do
      before :each do
        @tokens = 3.times.map { AuthenticationToken.generate(user: user) }
      end

      it 'old token is still valid' do
        expect(AuthenticationToken.where(user, @tokens.first.raw)).to be
      end

      it 'new token is valid' do
        expect(AuthenticationToken.where(user, @tokens.last.raw)).to be
      end
    end
  end

  describe '#authenticate' do
    it 'finds a token if there is one' do
      token = AuthenticationToken.generate(user: user)

      found_token = AuthenticationToken.authenticate(user, token.raw)
      expect(found_token).to be_a(AuthenticationToken)
      expect(found_token.user).to eq(user)
    end

    it 'invalidates itself' do
      token = AuthenticationToken.generate(user: user)

      found_token = AuthenticationToken.authenticate(user, token.raw)

      expect(AuthenticationToken.authenticate(user, token.raw)).to be_nil
    end

    it 'invalidates other tokens' do
      tokens = 3.times.map { AuthenticationToken.generate(user: user) }

      AuthenticationToken.authenticate(user, tokens.first.raw)

      expect(AuthenticationToken.authenticate(user, tokens.second.raw)).to be_nil
      expect(AuthenticationToken.authenticate(user, tokens.third.raw)).to be_nil
    end
  end

end
