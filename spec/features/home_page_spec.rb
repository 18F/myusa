require 'feature_helper'

describe 'Home Page' do
  let(:user) { FactoryGirl.create(:user) }
  let(:email) { user.email }
  let(:message) { "I'm sold. I want to enter all my profile data in MyUSA!" }

  before :each do
    @home_page = HomePage.new
  end

  shared_examples 'user contact form' do
    scenario 'user can contact us' do
      @home_page.load
      @home_page.contact_form.message.set(message)
      @home_page.submit_contact_form
      open_email('myusa@gsa.gov')
      expect(current_email).to have_content(message)
    end
  end

  context 'without javascript' do
    it_behaves_like 'user contact form'

    it 'displays an alert message' do
      @home_page.load
      @home_page.contact_form.message.set(message)
      @home_page.submit_contact_form
      expect(@home_page.contact_flash_no_js).to have_content('Thank you. Your message has been sent.')
    end

    it 'displays an alert message' do
      @home_page.load
      @home_page.submit_contact_form
      expect(@home_page.contact_flash_no_js).to have_content('Could not send empty message.')
    end
  end

  context 'with javascript', js: true do
    it_behaves_like 'user contact form'

    it 'displays an alert message' do
      @home_page.load
      @home_page.contact_form.message.set(message)
      @home_page.submit_contact_form
      expect(@home_page.contact_flash).to have_content('Thank you. Your message has been sent.')
    end

    it 'displays empty message alert' do
      @home_page.load
      @home_page.submit_contact_form
      expect(@home_page.contact_flash).to have_content('Could not send empty message.')
    end
  end
end
