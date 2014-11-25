require 'feature_helper'

describe 'Mobile Confirmation', sms: true do
  let(:mobile_confirmation_page) { MobileConfirmationPage.new }
  let(:sms_page) { TwoFactor::SmsPage.new}
  let(:account_settings_page) { AccountSettingsPage.new }

  let(:user) { FactoryGirl.create(:user) }
  let(:phone_number) { '800-555-3455' }


  before :each do
    login user
    mobile_confirmation_page.load
  end

  context 'after entering phone number' do
    before :each do
      mobile_confirmation_page.mobile_number.set phone_number
      mobile_confirmation_page.submit.click
    end

    scenario 'user is prompted to enter code' do #redirected to 2FA/SMS flow' do
      expect(sms_page).to be_displayed
    end

    context 'after completing 2FA/SMS flow' do
      before :each do
        open_last_text_message_for(phone_number)
        code = current_text_message.body.match /\d{6}/
        sms_page.token.set code
        sms_page.submit.click
      end

      scenario 'user is redirected to account settings page' do
        expect(account_settings_page).to be_displayed
      end
    end
  end
end
