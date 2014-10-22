require 'spec_helper'

describe Notification do
  let(:user) { FactoryGirl.create(:user) }
  let(:client_app) { FactoryGirl.create(:application) }

  describe '#create' do
    it 'sends a notification email when a notification is created' do
      expect do
        Notification.create!({subject: "Notification", received_at: Time.now - 1.hour, body: "This is a notification", user_id: user.id, app_id: client_app.id})
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
