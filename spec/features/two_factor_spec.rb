require 'feature_helper'

describe 'Two Factor Authentication', sms: true do
  let(:admin_page) { AdminPage.new }
  let(:sms_page) { TwoFactorAuthentication::SmsPage.new}

  let(:user) { FactoryGirl.create(:admin_user, :with_mobile_number) }
  let(:phone_number) { '800-555-3455' }

  def receive_code
    open_last_text_message_for(phone_number)
    expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
    current_text_message.body.match /\d{6}/
  end

  before :each do
    login user
  end

  scenario 'visiting an admin-only page redirects to sms flow' do
    admin_page.load
    expect(sms_page).to be_displayed
  end

  scenario 'user can receive sms code' do
    sms_page.load
    expect(receive_code).to_not be_nil
  end

  scenario 'user can resend code' do
    sms_page.load
    first_code = receive_code
    sms_page.resend_link.click
    expect(sms_page).to be_displayed
    expect(second_code = receive_code).to_not be_nil
    expect(second_code).to_not eql(first_code)
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
