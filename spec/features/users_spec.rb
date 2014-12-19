
require 'feature_helper'

describe 'Users' do
  let(:email) { 'test-user@testy.com' }
  let(:user) { FactoryGirl.create(:user, email: email) }

  let(:sign_in_page) { SignInPage.new }
  let(:profile_page) { ProfilePage.new }

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

      it "should change the user's city" do
        profile_page.city.set 'Enfield'
        profile_page.submit.click
        expect(profile_page).to be_displayed
        expect(profile_page.city.value).to eq 'Enfield'
      end

    end
  end

end
