require 'feature_helper'

describe 'Admin' do
  let(:profile_page) { ProfilePage.new }
  let(:admin_page) { AdminPage.new }

  let(:user) { FactoryGirl.create(:admin_user, :with_mobile_number) }
  let(:two_factor) { false }

  before :each do
    login user, two_factor: two_factor
  end

  describe 'navigation to admin page' do
    before :each do
      profile_page.load
    end

    context 'user is admin' do
      let(:two_factor) { true }

      it 'can navigate to admin from dropdown menu' do
        profile_page.dropdown_navigation_toggle.click
        profile_page.dropdown_navigation.admin_link.click
        expect(admin_page).to be_displayed
      end

      it 'can navigate to admin from profile nav' do
        profile_page.profile_navigation.admin_link.click
        expect(admin_page).to be_displayed
      end
    end

    context 'user is not admin' do
      let(:user) { FactoryGirl.create(:user) }

      it 'does not have admin link in drop down menu' do
        profile_page.dropdown_navigation_toggle.click
        expect(profile_page.dropdown_navigation).to_not have_admin_link
      end

      it 'does not have admin link profile nav' do
        expect(profile_page.profile_navigation).to_not have_admin_link
      end
    end
  end
end
