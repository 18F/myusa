require 'feature_helper'

describe 'Mobile Confirmation', sms: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:phone_number) { '800-555-3455' }

  before :each do
    login user
    @mobile_confirmation_page = MobileConfirmationPage.new
    @mobile_confirmation_page.load
  end

  scenario 'user can enter mobile number' do
    @mobile_confirmation_page.mobile_number.set phone_number
    @mobile_confirmation_page.submit.click

    expect(@mobile_confirmation_page).to be_displayed
    expect(@mobile_confirmation_page.heading).to have_content('Enter the code')
  end

  scenario 'user can skip mobile entry' do
    @mobile_confirmation_page.skip.click

    expect(@mobile_confirmation_page).to be_displayed
    expect(@mobile_confirmation_page.heading).to have_content('Welcome to MyUSA')
  end

  scenario 'user can receive and enter confirmation code' do
    @mobile_confirmation_page.mobile_number.set phone_number
    @mobile_confirmation_page.submit.click

    expect(@mobile_confirmation_page).to be_displayed
    open_last_text_message_for(phone_number)
    expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
    raw_token = current_text_message.body.match /\d{6}/

    @mobile_confirmation_page.mobile_number_confirmation_token.set raw_token
    @mobile_confirmation_page.submit.click

    expect(@mobile_confirmation_page).to be_displayed
    expect(@mobile_confirmation_page.heading).to have_content('Welcome to MyUSA')
    expect(@mobile_confirmation_page).to have_content('Your mobile number has been successfully added')
  end

  scenario 'user can resend code' do
    @mobile_confirmation_page.mobile_number.set phone_number
    @mobile_confirmation_page.submit.click

    expect(@mobile_confirmation_page).to be_displayed
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
