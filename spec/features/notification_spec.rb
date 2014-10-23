require 'feature_helper'

describe 'Notifications' do
  let(:home_page) { HomePage.new }
  let(:notification_settings_page) { NotificationSettingsPage.new }

  let(:user) { FactoryGirl.create(:user) }
  let(:client_app) { FactoryGirl.create(:application, name: 'App') }
  let(:unsubscribe_text) { 'Unsubscribe' }

  describe 'Receiving a notification' do
    # before :each do
    #   clear_emails
    #   FactoryGirl.create(:notification, user: user, app: client_app)
    #   open_email(user.email)
    # end
    #
    # scenario 'user can unsubscribe' do
    #   current_email.click_link(unsubscribe_text)
    #   expect(home_page).to be_displayed
    #   expect(home_page.flash_message).to have_content "You have been unsubscribed from App!"
    # end
  end

  describe 'Notification Settings' do
    before :each do
      login(user)
      notification_settings_page.load
      expect(notification_settings_page).to be_displayed
    end

    scenario 'user can disable email notifications' do
      notification_settings_page.myusa_settings.email_off_link.click

      expect(notification_settings_page).to be_displayed
      expect(notification_settings_page.myusa_settings).to have_email_on_link
    end

    scenario 'user can re-enable email notifications' do
      notification_settings_page.myusa_settings.email_off_link.click
      notification_settings_page.myusa_settings.email_on_link.click

      expect(notification_settings_page).to be_displayed
      expect(notification_settings_page.myusa_settings).to have_email_off_link
    end
  end

end
