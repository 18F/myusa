require 'feature_helper'

describe 'Home Page' do
  let(:user) { FactoryGirl.create(:user) }
  let(:email) { user.email }
  let(:message) { "I'm sold. I want to enter all my profile data in MyUSA!" }
  let(:display_message) { @home_page.contact_flash }

  before :each do
    @home_page = HomePage.new
    @home_page.submit_contact_form(message)
  end

  shared_examples 'user contact form' do
    scenario 'user can contact us' do
      expect(display_message).to have_content('Thank you. Your message has been sent.')
    end
  end

  context 'without javascript' do
    let(:display_message) { @home_page.contact_flash_no_js }

    it 'Displays message in email' do
      open_email('myusa@gsa.gov')
      expect(current_email).to have_content(message)
    end

    it_behaves_like 'user contact form'
  end

  context 'with javascript', js: true do
    it_behaves_like 'user contact form'
  end
end
