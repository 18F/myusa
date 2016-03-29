require 'feature_helper'

describe 'Home Page' do
  let(:user) { FactoryGirl.create(:user) }
  let(:email) { user.email }
  let(:message) { "I'm sold. I want to enter all my profile data in MyUSA!" }
  let(:display_message) { @home_page.contact_flash }
  let(:message_area) { @home_page.contact_form.message }

  before :each do
    @home_page = HomePage.new
    @home_page.submit_contact_form(message, email)
  end

  shared_examples 'user contact form' do
    scenario 'contact form displays reset fields after submission' do
      expect(message_area.value).to be_blank
    end

    scenario 'contact form displays notice after submission' do
      expect(display_message).to have_content(
        'Thank you. Your message has been sent.'
      )
    end
  end

  it 'displays message and email address in email' do
    open_email('myusa@gsa.gov')
    expect(current_email).to have_content(message)
    expect(current_email).to have_content(email)
  end

  # TODO: Marking these tests pending until we have a more
  # solidified version of the app to create solid integration tests.

  context 'without javascript' do
    pending "waiting on frontend refactor" do
      it_behaves_like 'user contact form' do
        let(:display_message) { @home_page.contact_flash_no_js }
      end
    end
  end

  context 'with javascript', js: true do
    pending "waiting on frontend refactor" do
      it_behaves_like 'user contact form' do
        let(:message_area) { @home_page.contact_form.message }
      end
    end
  end
end
