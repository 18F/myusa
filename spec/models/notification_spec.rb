require 'rails_helper'

describe Notification do
  describe '#create' do
    let(:user) { FactoryGirl.create(:user) }
    let(:client_app) { FactoryGirl.create(:application) }
    let(:authorization) { FactoryGirl.create(:authorization, user: user, application: client_app) }

    subject { FactoryGirl.create(:notification, authorization: authorization) }

    context 'user has not blocked email notifications' do
      it 'sends an email' do
        expect { subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
      it 'creates an unsubscribe token for the user' do
        expect { subject }.to change(user.unsubscribe_tokens, :count).by(1)
      end
    end

    context 'user blocks email notifications' do
      let(:authorization) { FactoryGirl.create(:authorization, user: user, application: client_app, notification_settings: { 'receive_email' => false }) }

      it 'does not send an email' do
        expect { subject }.to_not change(ActionMailer::Base.deliveries, :count)
      end
      it 'does not create an unsubscribe token' do
        expect { subject }.to_not change(UnsubscribeToken, :count)
      end
    end
  end
end
