
require 'feature_helper'

describe 'Users' do
  let(:user) { create_confirmed_user_with_profile }

  describe 'change your name' do
    context 'user is signed in' do
      before do
        login(user)
        @page = EditProfilePage.new
        @page.load
      end

      it "should change the user's name when first or last name changes" do
        fill_in 'First name', with: 'Jane'
        click_button 'Update Profile'
        expect(page).to have_content 'Your profile was sucessfully updated.'
        expect(page).to have_content 'First name: Jane'
      end
    end
  end
end
