require 'rails_helper'

describe Notification do
  describe '#create' do
    let(:user) { FactoryGirl.create(:user) }
    let(:client_app) { FactoryGirl.create(:application) }
    subject { FactoryGirl.create(:notification, user: user, app: client_app) }

    context 'user has not blocked email notifications' do
      it 'sends an email' do
        expect { subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
      it 'creates an unsubscribe token for the user' do
        expect { subject }.to change(user.unsubscribe_tokens, :count).by(1)
      end
    end

    context 'user blocks email notificaitons' do
      before :each do
        key = "notification_settings.app_#{client_app.id}.delivery_methods.email"
        user.settings[key] = false
        user.save!
      end

      it 'does not send an email' do
        expect { subject }.to_not change(ActionMailer::Base.deliveries, :count)
      end
      it 'does not create an unsubscribe token' do
        expect { subject }.to_not change(UnsubscribeToken, :count)
      end
    end
  end
end
