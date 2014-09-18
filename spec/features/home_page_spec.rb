require 'feature_helper'

describe 'Home Page' do
  let(:user) { FactoryGirl.create(:user) }
  let(:email) { user.email }
  let(:message) { "I'm sold. I want to enter all my profile data in MyUSA!" }

  before :each do
    @home_page = HomePage.new
  end

  context 'without javascript' do
    it 'displays an alert message' do
      @home_page.submit_contact_form(message)
      open_email('myusa@gsa.gov')
      expect(current_email).to have_content(message)
      expect(@home_page.contact_flash_no_js).to have_content('Thank you. Your message has been sent.')
    end
  end

  context 'with javascript', js: true do
    it 'displays an alert message' do
      @home_page.submit_contact_form('message')
      expect(@home_page.contact_flash).to have_content('Thank you. Your message has been sent.')
    end
  end
end
