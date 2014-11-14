require 'feature_helper'

describe 'Account Settings' do
  let(:account_settings_page) { AccountSettingsPage.new }
  let(:home_page) { HomePage.new }
  let(:mobile_confirmation_page) { MobileConfirmationPage.new }
  let(:sms_page) { TwoFactorAuthentication::SmsPage.new}
  # let(:profile_page) { ProfilePage.new }

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

  describe '2FA Settings' do
    before :each do
      login(user, two_factor: two_factor)
      account_settings_page.load
    end

    shared_examples 'mobile recovery entry' do
      it 'can start two factor configure flow' do
        account_settings_page.two_factor.link.click
        expect(mobile_confirmation_page).to be_displayed
      end
    end

    context 'two-factor authentication is not configured' do
      let(:user) { FactoryGirl.create(:user) }
      let(:two_factor) { false }

      it 'enable link is present' do
        expect(account_settings_page.two_factor.link).to have_content('enable')
      end

      include_examples 'mobile recovery entry'
    end

    context 'two-factor authentication is configured' do
      let(:user) { FactoryGirl.create(:user, :with_2fa) }
      let(:two_factor) { true }

      it 'configure link is present' do
        expect(account_settings_page.two_factor.link).to have_content('configure')
      end

      include_examples 'mobile recovery entry'
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
        expect(account_settings_page).to be_displayed
        expect(account_settings_page).to have_content 'You must enter the email address that matches this account.'
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
