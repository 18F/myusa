require 'rails_helper'

describe UnsubscribeToken do
  let(:user) { FactoryGirl.create(:user) }
  let(:client_app) { FactoryGirl.create(:application) }
  let(:delivery_method) { "email" }
  let(:authorization) { FactoryGirl.create(:authorization, user: user, application: client_app) }
  let(:notification) { FactoryGirl.create(:notification, authorization: authorization) }
  let(:authenticate_result) { UnsubscribeToken.generate(user: user, notification: notification) }

  describe '#unsubscribe' do
    before :each do
      UnsubscribeToken.unsubscribe(user, authenticate_result.raw, delivery_method)
    end

    context 'call to authenticate succeeds' do
      it 'unsubscribes user from notifications from app' do
        expect(authorization.reload.notification_settings['receive_email']).to be_falsey
      end
    end

    context 'call to authenticate fails' do
      let(:authenticate_result) { double(:unsubscribe_token, raw: 'foobar') }

      it 'does not unsubscribe user from notifications from app' do
        expect(authorization.reload.notification_settings['receive_email']).to be_truthy
      end
    end
  end
end
