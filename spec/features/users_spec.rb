
require 'feature_helper'

describe 'Users' do
  let(:user) { create_confirmed_user_with_profile }

  describe 'change your name' do
    context 'user is signed in' do
      before do
        login(user)
        @page = EditProfilePage.new
        @page.load
        @results_page = ProfilePage.new
      end

      it "should change the user's name when first or last name changes" do
        @page.first_name.set 'Jane'
        @page.submit.click
        expect(@results_page).to be_displayed
        expect(@results_page.first_name).to have_content('Jane')
      end
    end
  end
end
