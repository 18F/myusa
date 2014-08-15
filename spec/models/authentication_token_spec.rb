require 'rails_helper'

describe AuthenticationToken, type: :model do

  describe '#generate' do
    it 'generates a token' do
      token = AuthenticationToken.generate(user_id: 1)
      expect(token.token).to be
    end
  end

  describe '#save' do
    it 'writes token to cache' do
      token = AuthenticationToken.new(user_id: 1)
      token.save
      expect(Rails.cache.fetch(AuthenticationToken.send(:cache_key, 1))).to be
    end

    it 'omits raw token' do
      expect(Rails.cache.fetch(AuthenticationToken.send(:cache_key, 1))[:raw]).to be_nil
    end
  end

  describe '#find_by_user_id' do
    it 'finds a token' do
      token = AuthenticationToken.new(user_id: 1)
      token.save
      expect(AuthenticationToken.find_by_user_id(1)).to be_a(AuthenticationToken)
    end
  end

  describe '#delete' do
    it 'destoys the cached token' do
      token = AuthenticationToken.generate(user_id: 1)
      token.delete
      expect(Rails.cache.fetch(token.send(:cache_key))).to be_nil
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
