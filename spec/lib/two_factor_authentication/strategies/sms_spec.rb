require 'spec_helper'
require 'two_factor_authentication/strategies/sms'

describe TwoFactorAuthentication::Strategies::Sms do
  include Warden::Spec::Helpers

  let(:user) { FactoryGirl.create(:user, :with_mobile_number) }
  let(:params) { {} }
  let(:env) { env_with_params('/', params) }

  before :each do
    setup_rack(success_app).call(env)
  end

  subject do
    TwoFactorAuthentication::Strategies::Sms.new(env)
  end

  describe '#valid?' do
    context 'user is not logged in' do
      it 'is not valid' do
        expect(subject).to_not be_valid
      end
    end

    context 'user is logged in' do
      before :each do
        env['warden'].set_user(user, scope: :user)
      end

      context 'invalid params' do
        it 'is not valid' do
          expect(subject).to_not be_valid
        end
      end

      context 'sms authentication code is in params' do
        let(:params) { { "sms[raw_token]" => 'bad token' }}

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe '#authenticate!' do
    let(:raw_token) { '123456' }

    before :each do
      env['warden'].set_user(user, scope: :user)
      allow(SmsCode).to receive(:new_token) { raw_token }
      user.create_sms_code!
      subject.authenticate!
    end

    context 'raw token is bad' do
      let(:params) { { "sms[raw_token]" => 'bad token' }}
      it 'does not set user' do
        expect(subject.user).to be_nil
      end
      it 'fails' do
        expect(subject.result).to eql(:failure)
        expect(subject.message).to eql(:sms_authentication_failed)
      end
    end

    context 'raw token matches' do
      let(:params) { { "sms[raw_token]" => raw_token }}
      it 'sets sms_code object' do
        expect(subject.user).to eql(user.sms_code)
      end
      it 'succeeds' do
        expect(subject.result).to eql(:success)
      end
    end
  end
end
