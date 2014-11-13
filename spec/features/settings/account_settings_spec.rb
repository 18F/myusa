require 'feature_helper'

describe 'Account Settings' do
  let(:account_settings_page) { AccountSettingsPage.new }
  let(:home_page) { HomePage.new }
  let(:sms_page) { TwoFactorAuthentication::SmsPage.new}
  let(:profile_page) { ProfilePage.new }

  describe 'visiting account settings page' do
    before :each do
      login(user)
      account_settings_page.load
    end

    context 'two factor is not configured' do
      let(:user) { FactoryGirl.create(:user) }

      it 'can access settings page' do
        expect(account_settings_page).to be_displayed
      end
    end

    context 'two-factor is configured' do
      let(:user) { FactoryGirl.create(:user, :with_2fa) }

      it 'two-factor authentication is required' do
        expect(sms_page).to be_displayed
      end
    end
  end

  describe 'Account Removal' do
    let(:user) { FactoryGirl.create(:user, :with_2fa) }
    let(:email) { user.email }
    before do
      login(user, two_factor: true)
      account_settings_page.load
      account_settings_page.delete_account.email.set email
      account_settings_page.delete_account.submit.click
    end

    context 'the incorrect email is entered' do
      let(:email) { 'wrong@example.com' }

      it 'displayes message when invalid email is entered' do
        expect(profile_page).to be_displayed
        expect(profile_page).to have_content 'You must enter the email ' \
          'address that matches this account.'
      end
    end

    context 'the correct email is entered' do
      it 'deletes the account when the correct email is entered' do
        expect(home_page).to be_displayed
        expect(home_page).to have_content 'Your account has been deleted'
      end
    end
  end

end
