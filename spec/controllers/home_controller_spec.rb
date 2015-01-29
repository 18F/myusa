require 'rails_helper'

describe HomeController do
  let(:from) { "Joe" }
  let(:email) { "chris@example.com" }
  let(:message) { "Your app is broken. Write better tests!" }

  let(:user) { FactoryGirl.create(:user, email: email) }

  describe "#contact_us" do
    before :each do
      mailer = double('mailer');
      expect(mailer).to receive(:deliver)
      expect(SystemMailer).to receive(:contact_email).with(from, email, message).and_return(mailer)
    end

    it 'sends us an email' do
      post :contact_us, contact_us: { from: from, return_email: email, message: message }
    end

    it 'uses current user\'s info if signed in' do
      sign_in user
      post :contact_us, contact_us: { from: from, message: message }
    end
  end
end
