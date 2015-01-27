
require 'feature_helper'

describe 'Users' do
  let(:email) { 'test-user@testy.com' }
  let(:user) { FactoryGirl.create(:user, email: email) }

  let(:sign_in_page) { SignInPage.new }
  let(:profile_page) { ProfilePage.new }
  let(:additional_profile_page) { AdditionalProfilePage.new }


  describe 'change your name' do
    context 'user is not signed in' do
      it 'should display need to sign in warning' do
        visit edit_profile_url
        expect(sign_in_page).to_not have_content(
          'You need to sign in or sign up before continuing'
        )
      end
    end

    context 'user is signed in' do
      before do
        login(user)
        profile_page.load
      end

      it "should change the user's name when first or last name changes" do
        profile_page.first_name.set 'Jane'
        profile_page.submit.click
        expect(profile_page).to be_displayed
        expect(profile_page.first_name.value).to eq 'Jane'
      end

      it "should allow setting a 'Yes/No' field to blank" do
        additional_profile_page.load
        additional_profile_page.is_student.select 'Yes'
        additional_profile_page.submit.click

        expect(additional_profile_page).to be_displayed
        expect(additional_profile_page.is_student.value).to eq 'true'

        additional_profile_page.is_student.select 'Not Specified'
        additional_profile_page.submit.click

        expect(additional_profile_page).to be_displayed
        expect(additional_profile_page.is_student.value).to be_blank
      end
    end
  end

end
