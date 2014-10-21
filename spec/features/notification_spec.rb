require 'feature_helper'

describe 'Notifications' do
  let(:home_page) { HomePage.new }

  let(:user) { FactoryGirl.create(:user) }
  let(:client_app) { FactoryGirl.create(:application, name: 'App') }
  let(:unsubscribe_text) { 'Unsubscribe' }

  describe 'Receiving a notification' do
    before :each do
      clear_emails
      FactoryGirl.create(:notification, user: user, app: client_app)
      open_email(user.email)
    end

    scenario 'user can unsubscribe' do
      current_email.click_link(unsubscribe_text)
      expect(home_page).to be_displayed
      expect(home_page.flash_message).to have_content "You have been unsubscribed from App!"
    end
  end

end
