require 'spec_helper'

describe ContactMailer do
  describe 'contact mailer' do
    let(:message) do { 'message' => 'test body',
                       'from' => 'example@example.com',
                       'return_field' => 'example@example.com' }
    end
    let(:mail) { ContactMailer.contact_email(message) }

    it 'renders the subject' do
      expect(mail.subject).to eql('Contact - MyUSA marketing page')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql(['myusa@gsa.gov'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['no-reply@test.my.usa.gov.'])
    end

    it 'includes message' do
      expect(mail.body.encoded).to include(message['message'])
    end
    it 'includes return field' do
      expect(mail.body.encoded).to include(message['return_field'])
    end
  end
end
