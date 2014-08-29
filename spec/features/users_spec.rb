
require 'feature_helper'

describe 'Users' do
  let(:user) { create_confirmed_user_with_profile }

  describe 'change your name' do
    context 'user is signed in' do
      before do
        login(user)
        @profile_edit_page = EditProfilePage.new
        @profile_edit_page.load
        @results_page = ProfilePage.new
      end

      it "should change the user's name when first or last name changes" do
        @profile_edit_page.first_name.set 'Jane'
        @profile_edit_page.submit.click
        expect(@results_page).to be_displayed
        expect(@results_page.first_name).to eq 'Jane'
      end

      it "should allow setting a 'Yes/No' field to blank" do
        @profile_edit_page.is_student.select 'Yes'
        @profile_edit_page.submit.click
        expect(@results_page).to be_displayed
        expect(@results_page.is_student).to eq 'Yes'

        @profile_edit_page.load
        @profile_edit_page.is_student.select ''
        @profile_edit_page.submit.click

        expect(@results_page).to be_displayed
        expect(@results_page.is_student).to be_blank
      end
    end
  end
end
