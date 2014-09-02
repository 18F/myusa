require 'spec_helper'

describe Devise::Strategies::EmailAuthenticatable do

  def env_with_params(path = "/", params = {}, env = {})
    method = params.delete(:method) || "GET"
    env = { 'HTTP_VERSION' => '1.1', 'REQUEST_METHOD' => "#{method}" }.merge(env)
    Rack::MockRequest.env_for("#{path}?#{Rack::Utils.build_query(params)}", env)
  end

  let(:params) { {} }

  subject do
    Devise::Strategies::EmailAuthenticatable.new(env_with_params("/", params))
  end

  describe '#valid?' do
    context 'neither email nor token are in params' do
      it 'is not valid' do
        expect(subject).to_not be_valid
      end
    end

    context 'both email and token are in params' do
      let(:params) { { email: 'test@example.com', token: 'foobar' } }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe '#authenticate!' do
    let(:email) { 'test@example.com' }
    let(:session) { Hash.new }

    before :each do
      @user = User.create(email: email)
      @token = AuthenticationToken.generate(user_id: @user.id, return_to: '/foobar')
      @raw = @token.raw

      allow(subject).to receive(:session).and_return(session)

      subject.authenticate!
    end

    shared_context 'bad token' do
      it 'does not set the user' do
        expect(subject.user).to be_nil
      end

      it 'fails' do
        expect(subject.result).to eq(:failure)
      end

      it 'sets messgae' do
        expect(subject.message).to eq(:invalid_token)
      end
    end

    shared_context 'good token' do

      it 'sets the user' do
        expect(subject.user).to be
      end

      it 'halts warden' do
        expect(subject).to be_halted
      end

      it 'invalidates the token' do
        expect(AuthenticationToken.authenticate(@user, @raw)).to be_nil
      end
    end

    context 'with nonsense string for token' do
      let(:params) { { email: email, token: 'foobar' } }
      include_examples 'bad token'
    end

    context 'with another user''s token' do
      let(:params) do
        user2 = User.create(email: 'otherguy@gsa.gov')
        token2 = AuthenticationToken.generate(user_id: user2.id, return_to: '/foobar')

        { email: email, token: token2.raw }
      end

      include_examples 'bad token'
    end

    context 'valid email and token combination' do
      let(:params) { { email: email, token: @raw } }

      include_examples 'good token'
    end
  end
end
