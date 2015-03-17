require 'feature_helper'

describe 'Two Factor Authentication', sms: true do
  let(:target_page) { TargetPage.new }
  let(:admin_page) { AdminPage.new }
  let(:sms_page) { TwoFactor::SmsPage.new}
  let(:mobile_confirmation_page) { MobileConfirmationPage.new }
  let(:account_settings_page) { AccountSettingsPage.new }

  let(:user) { FactoryGirl.create(:admin_user, mobile_number: phone_number) }
  let(:phone_number) { '800-555-3455' }

  def receive_code
    open_last_text_message_for(phone_number)
    expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
    current_text_message.body.match /\d{6}/
  end

  before :each do
    login user
  end

  context 'visiting an admin-only page' do
    before :each do
      admin_page.load
    end

    context 'if user has mobile number configured' do
      it 'redirects to sms flow' do
        expect(sms_page).to be_displayed
      end
    end

    context 'if user does not have mobile number configured' do
      let(:user) { FactoryGirl.create(:admin_user) }

      it 'redirects to mobile confirmation page' do
        expect(mobile_confirmation_page).to be_displayed
      end
    end

    scenario 'user sees their mobile number on the form' do
      expect(sms_page.heading.text).to include("Enter the code delivered to the mobile number ending in #{phone_number.last(4)}")
    end

    scenario 'user can receive sms code' do
      expect(receive_code).to_not be_nil
    end

    scenario 'user can resend code' do
      first_code = receive_code
      sms_page.resend_link.click
      expect(sms_page).to be_displayed
      expect(second_code = receive_code).to_not be_nil
      expect(second_code).to_not eql(first_code)
    end
  end

  context 'user has not enabled two-factor' do
    let(:user) { FactoryGirl.create(:user, two_factor_required: false, mobile_number: nil) }
    before :each do
      account_settings_page.load
    end

    it 'user cannot require two-factor' do
      expect(account_settings_page.two_factor).to_not have_two_factor_required_checkbox
    end
  end

  context 'user has enabled two-factor' do
    def code; receive_code; end
    let(:user) { FactoryGirl.create(:user, two_factor_required: false, mobile_number: phone_number) }
    before :each do
      account_settings_page.load
      sms_page.token.set code
      sms_page.submit.click
    end

    it 'user can require two-factor' do
      expect(account_settings_page.two_factor).to have_two_factor_required_checkbox
    end
  end

  context 'user has required two-factor' do
    let(:user) { FactoryGirl.create(:user, two_factor_required: true, mobile_number: phone_number) }

    before :each do
      target_page.load
    end

    it 'redirects to sms flow' do
      expect(sms_page).to be_displayed
    end
  end

  context 'user submits code' do
    def code; receive_code; end

    before :each do
      admin_page.load
      sms_page.token.set code
      sms_page.submit.click
    end

    context 'code is bad' do
      def code; 'foobar'; end

      scenario 'shows error and displays sms form' do
        expect(sms_page).to be_displayed
        expect(sms_page).to have_flash_message('Please check the number sent to your mobile and re-enter that code')
      end

      scenario 'user can resend code' do
        first_code = receive_code
        sms_page.flash_resend_link.click
        expect(sms_page).to be_displayed
        expect(second_code = receive_code).to_not be_nil
        expect(second_code).to_not eql(first_code)
      end
    end

    context 'code is correct' do
      scenario 'redirects back' do
        expect(admin_page).to be_displayed
      end
    end
  end
end
