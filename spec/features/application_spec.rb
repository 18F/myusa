require 'feature_helper'

describe 'Applications' do
  let(:email) { 'test-user@testy.com' }
  let(:user) { create_confirmed_user_with_profile(email: email) }

  describe 'applications new' do
    context 'user is signed in' do
      before do
        login(user)
        @application_new_page = NewApplicationPage.new
        @application_new_page.load
      end

      it "should change the user's name when first or last name changes" do
        expect(@application_new_page).to have_content(
          'Please provide '\
          'a secure (https) URL for an image that identifies your application.'\
          ' The image should be 120px by 120px in size.'
        )
      end
    end
  end
end