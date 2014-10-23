require 'rails_helper'

describe UnsubscribeToken do
  let(:user) { FactoryGirl.create(:user) }
  let(:client_app) { FactoryGirl.create(:application) }
  let(:settings_key) { "notification_settings.app_#{client_app.id}.delivery_methods" }
  let(:notification) { FactoryGirl.create(:notification, user: user, app: client_app) }
  let(:authenticate_result) { UnsubscribeToken.generate(user: user, notification: notification) }

  describe '#unsubscribe' do
    before :each do
      UnsubscribeToken.unsubscribe(user, authenticate_result.raw, 'email')
    end

    context 'call to authenticate succeeds' do
      it 'unsubscribes user from notifications from app' do
        expect(user.settings[settings_key]).to_not include('email')
      end
    end

    context 'call to authenticate fails' do
      let(:authenticate_result) { double(:unsubscribe_token, raw: 'foobar') }

      it 'does not unsubscribe user from notifications from app' do
        expect(user.settings[settings_key]).to be_nil
      end
    end
  end
end
