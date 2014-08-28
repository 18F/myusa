require 'rails_helper'

describe AuthenticationToken, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:date) { Date.new(1999, 12, 31) }

  before(:each) { Timecop.freeze(date) }
  after(:each) { Timecop.return }

  describe 'default scope' do
    it 'does not find expired tokens' do
      AuthenticationToken.create(user: user)
      Timecop.travel(date + 6.hours)
      expect(AuthenticationToken.all).to be_empty
    end
  end

  describe '#expired' do
    it 'finds only expired tokens' do
      old_token = AuthenticationToken.create(user: user)
      Timecop.travel(date + 6.hours)
      new_token = AuthenticationToken.create(user: user)

      expired_tokens = AuthenticationToken.expired.all

      expect(expired_tokens).to include(old_token)
      expect(expired_tokens).to_not include(new_token)
    end
  end

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

    it 'fails for expired token' do
      token = AuthenticationToken.generate(user: user)

      Timecop.travel(date + 6.hours)
      expect(AuthenticationToken.authenticate(user, token.raw)).to be_nil
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
