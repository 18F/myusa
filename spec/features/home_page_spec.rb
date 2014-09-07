require 'feature_helper'

describe 'Home Page' do
  let(:user) { FactoryGirl.create(:user) }
  let(:email) { user.email }
  let(:message) { "I'm sold. I want to enter all my profile data in MyUSA!" }

  before :each do
    @home_page = HomePage.new
  end

  scenario 'user can contact us' do
    @home_page.load
    @home_page.contact_form.message.set(message)
    @home_page.contact_form.from.set(email)
    @home_page.contact_form.submit.click

    @home_page.wait_for_contact_flash

    open_email('myusa@gsa.gov')

    expect(current_email).to have_content(message)
  end
end
