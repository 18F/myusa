require 'feature_helper'

describe 'Mobile Confirmation', sms: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:phone_number) { '800-555-3455' }

  def receive_code
    open_last_text_message_for(phone_number)
    expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
    current_text_message.body.match /\d{6}/
  end

  def enter_code!(code)
    @mobile_confirmation_page.mobile_number_confirmation_token.set code # 'bad token'
    @mobile_confirmation_page.submit.click
  end

  before :each do
    login user
    @mobile_confirmation_page = MobileConfirmationPage.new
    @mobile_confirmation_page.load
  end

  scenario 'user can skip mobile entry' do
    @mobile_confirmation_page.skip.click

    expect(@mobile_confirmation_page).to be_displayed
    expect(@mobile_confirmation_page.heading).to have_content('Welcome to MyUSA')
  end

  context 'after entering phone number' do
    before :each do
      @mobile_confirmation_page.mobile_number.set phone_number
      @mobile_confirmation_page.submit.click

      expect(@mobile_confirmation_page).to be_displayed
    end

    scenario 'user is prompted to enter code' do
      expect(@mobile_confirmation_page.heading).to have_content('Enter the code')
    end

    context 'valid code' do
      scenario 'user can receive and enter confirmation code' do
        raw_token = receive_code
        enter_code! raw_token

        expect(@mobile_confirmation_page).to be_displayed
        expect(@mobile_confirmation_page.heading).to have_content('Welcome to MyUSA')
        expect(@mobile_confirmation_page).to have_content('Your mobile number has been successfully added')
        expect(@mobile_confirmation_page).to have_redirect_link
      end
    end

    context 'code does not match' do
      scenario 'user gets a helpful error message' do
        enter_code! 'bad token'

        expect(@mobile_confirmation_page).to be_displayed
        expect(@mobile_confirmation_page.flash_message).to have_content('Please check the number sent to your mobile and re-enter that code')
        expect(@mobile_confirmation_page).to have_flash_resend_link
        expect(@mobile_confirmation_page).to have_flash_reenter_link
      end
    end

    scenario 'user can resend code' do
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
      first_token = current_text_message.body.match /\d{6}/

      @mobile_confirmation_page.resend.click

      expect(@mobile_confirmation_page).to be_displayed
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
      second_token = current_text_message.body.match /\d{6}/

      expect(first_token).to_not match(second_token)
    end
  end
end
