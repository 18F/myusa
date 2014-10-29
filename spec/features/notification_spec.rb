require 'feature_helper'

describe 'Notifications' do
  let(:home_page) { HomePage.new }
  let(:notification_settings_page) { NotificationSettingsPage.new }
  let(:unsubscribe_landing_page) { UnsubscribeLandingPage.new }

  let(:user) { FactoryGirl.create(:user) }
  let(:client_app) { FactoryGirl.create(:application, name: 'App', scopes: 'notifications') }
  let(:unsubscribe_text) { 'Unsubscribe' }

  describe 'Receiving a notification' do
    before :each do
      clear_emails
      token = FactoryGirl.create(:access_token, resource_owner: user, application: client_app, scopes: 'notifications')
      FactoryGirl.create(:notification, authorization: token.authorization) # user: user, app: client_app)
      open_email(user.email)
    end

    scenario 'user can unsubscribe' do
      current_email.click_link(unsubscribe_text)
      expect(unsubscribe_landing_page).to be_displayed
      unsubscribe_landing_page.notification_settings_link.click

      sign_in_with_email(user.email)

      expect(notification_settings_page).to be_displayed

      app_notification_settings = notification_settings_page.app_settings.select {|row| row.label.text.include?(client_app.name)}.first

      expect(app_notification_settings).to have_email_off_button
    end
  end

  describe 'Notification Settings' do
    before :each do
      FactoryGirl.create(:access_token, resource_owner: user, application: client_app, scopes: 'notifications')
      login(user)
      notification_settings_page.load
      expect(notification_settings_page).to be_displayed
    end

    scenario 'user can disable myusa email notifications' do
      notification_settings_page.myusa_settings.email_on_button.click

      expect(notification_settings_page).to be_displayed
      expect(notification_settings_page.myusa_settings).to have_email_off_button
    end

    scenario 'user can re-enable myusa email notifications' do
      notification_settings_page.myusa_settings.email_on_button.click
      notification_settings_page.myusa_settings.email_off_button.click

      expect(notification_settings_page).to be_displayed
      expect(notification_settings_page.myusa_settings).to have_email_on_button
    end

    scenario 'user can disable app email notifications' do
      notification_settings_page.app_settings.first.email_on_button.click

      expect(notification_settings_page).to be_displayed
      expect(notification_settings_page.app_settings.first).to have_email_off_button
    end

    scenario 'user can re-enable app email notifications' do
      notification_settings_page.app_settings.first.email_on_button.click
      notification_settings_page.app_settings.first.email_off_button.click

      expect(notification_settings_page).to be_displayed
      expect(notification_settings_page.app_settings.first).to have_email_on_button
    end
  end

end
