require 'spec_helper'

describe NotificationMailer do
  describe 'notification mailer' do
    let(:user) { FactoryGirl.create(:user) }
    let(:email_subject) { 'test subject' }
    let(:received_at) { Time.now }
    let(:app) { FactoryGirl.create(:application, url: 'https://example.com/') }
    let(:body) { 'test body' }
    let(:notification) do
      Notification.new(
        subject: email_subject,
        received_at: received_at,
        user_id: user.id,
        app_id: app.id,
        body: body)
    end

    subject { NotificationMailer.notification_email(notification) }
    its(:from) { should eql ['no-reply@' + ActionMailer::Base.default_url_options[:host]] }
    its(:subject) { should eql notification.subject }
    its(:reply_to) { should contain_exactly 'myusa@gsa.gov' }
    its('body.encoded') { should have_content notification.body }
  end
end
