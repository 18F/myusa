require 'rails_helper'

describe AuthenticationToken, type: :model do

  describe '#generate' do
    it 'generates a token' do
      token = AuthenticationToken.generate(user_id: 1)
      expect(token.token).to be
    end

    it 'does not invalidate old tokens' do
      token1 = AuthenticationToken.generate(user_id: 1)
      token2 = AuthenticationToken.generate(user_id: 1)
      expect(token1).to be_valid
      expect(token2).to be_valid
    end
  end

  describe '#save' do
    let(:token) { AuthenticationToken.create(user_id: 1) }

    it 'writes token to cache' do
      expect(Rails.cache.fetch(AuthenticationToken.send(:cache_key, token.raw))).to be
    end

    it 'omits raw token' do
      expect(Rails.cache.fetch(AuthenticationToken.send(:cache_key, token.raw))[:raw]).to be_nil
    end
  end

  describe '#find' do #_by_user_id' do
    it 'finds a token if there is one' do
      token = AuthenticationToken.new(user_id: 1)
      token.save

      found_token = AuthenticationToken.find(token.raw)
      expect(found_token).to be_a(AuthenticationToken)
      expect(found_token.user_id).to eq(1)
    end
    it 'returns an empty token if none exists' do
      expect(AuthenticationToken.find('foobar')).to be_a(AuthenticationToken)
    end
    it 'returns an empty token if nothing is passed' do
      expect(AuthenticationToken.find(nil)).to be_a(AuthenticationToken)
    end
  end

  describe '#delete' do
    it 'destoys the cached token' do
      token = AuthenticationToken.generate(user_id: 1)
      token.delete
      expect(Rails.cache.fetch(AuthenticationToken.send(:cache_key, token.raw))).to be_nil
    end
  end

  describe '#valid?' do
    context 'raw token is nil' do
      it 'should be false' do
        token = AuthenticationToken.new(user_id: 1)
        token.raw = nil
        expect(token).to_not be_valid
      end
    end

    context 'raw token is invalid' do
      it 'should be false' do
        token = AuthenticationToken.new(user_id: 1)
        token.raw = 'foobar'
        expect(token).to_not be_valid
      end
    end

    context 'raw token matches token' do
      it 'should be true' do
        token = AuthenticationToken.new(user_id: 1)
        token.generate_token
        expect(token).to be_valid
      end
    end
  end

end
