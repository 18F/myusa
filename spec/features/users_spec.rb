
require 'feature_helper'

describe 'Users' do
  let(:email) { 'test-user@testy.com' }
  let(:user) { create_confirmed_user_with_profile(email: email) }

  describe 'change your name' do
    context 'user is signed in' do
      before do
        login(user)
        @profile_edit_page = EditProfilePage.new
        @profile_edit_page.load
        @additional_profile_page = AdditionalProfilePage.new
        @results_page = ProfilePage.new
        @additional_results_page = AdditionalProfilePage.new
      end

      it "should change the user's name when first or last name changes" do
        @profile_edit_page.first_name.set 'Jane'
        @profile_edit_page.submit.click
        expect(@results_page).to be_displayed
        expect(@results_page.first_name.value).to eq 'Jane'
      end

      it "should allow setting a 'Yes/No' field to blank" do
        @additional_profile_page.load
        @additional_profile_page.is_student.select 'Yes'
        @additional_profile_page.submit.click

        expect(@additional_results_page).to be_displayed
        expect(@additional_results_page.is_student.value).to eq 'true'

        @additional_results_page.is_student.select 'Not Specified'
        @additional_results_page.submit.click

        expect(@additional_results_page).to be_displayed
        expect(@additional_results_page.is_student.value).to be_blank
      end
    end
  end

  describe 'delete your account your name' do
    context 'user is signed in' do
      before do
        login(user)
        @profile_page = ProfilePage.new
        @delete_account_page = DeleteAccountPage.new
        @profile_page.load
        @profile_page.delete_account_button.click
      end

      it 'displays the warning message' do
        expect(@delete_account_page).to be_displayed
        expect(@delete_account_page).to have_content 'This will delete all ' \
          'of your account data, applications, and history. Proceed with ' \
          'caution!'
        expect(@delete_account_page).to have_content 'Deletion of your ' \
          'account is permanent and cannot be undone.'
      end

      context 'the incorrect email is entered' do
        before do
          @delete_account_page.enter_email.set 'wrong'
          @delete_account_page.delete_button.click
        end

        it 'displayes message when invalid email is entered' do
          expect(@profile_page).to be_displayed
          expect(@profile_page).to have_content 'You must enter the email ' \
            'address that matches this account.'
        end
      end

      context 'the correct email is entered' do
        before do
          @home_page = HomePage.new
          @delete_account_page.enter_email.set email
        end

        it 'displays the warning message' do
          expect(@delete_account_page).to have_content 'Deletion of your ' \
            'account is permanent and cannot be undone.'
        end

        it 'deletes the account when the correct email is entered' do
          @delete_account_page.delete_button.click
          expect(@home_page).to be_displayed
          expect(@home_page).to have_content 'Your account has been deleted'
        end
      end
    end
  end
end
