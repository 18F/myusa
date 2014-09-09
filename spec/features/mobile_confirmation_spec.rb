require 'feature_helper'

describe 'Mobile Confirmation' do
  let(:user) { FactoryGirl.create(:user) }

  before :each do
    login user
    @mobile_confirmation_page = MobileConfirmationPage.new
    @mobile_confirmation_page.load
  end

  scenario 'user can enter mobile number' do
    @mobile_confirmation_page.mobile_number.set '800-555-3455'
    @mobile_confirmation_page.submit.click
    expect(@mobile_confirmation_page).to be_displayed
    expect(@mobile_confirmation_page.heading).to have_content('Enter the code')
    # expect(@mobile_confirmation_page).to have_mobile_confirmation_token
  end

  scenario 'user can enter confirmation code'
end
