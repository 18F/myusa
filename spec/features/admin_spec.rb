require 'feature_helper'

describe 'Admin' do
  let(:profile_page) { ProfilePage.new }
  let(:admin_page) { AdminPage.new }

  let(:user) { FactoryGirl.create(:admin_user, :with_2fa) }
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

  describe 'app approval' do
    before :each do
      FactoryGirl.create(:application, name: 'App 1', public: false, requested_public_at: Time.now)
      FactoryGirl.create(:application, name: 'App 2', public: false, requested_public_at: Time.now)
      login user, two_factor: true
      admin_page.load
    end

    it 'can see apps pending approval' do
      expect(admin_page.apps.count).to eql(2)
    end

    it 'can approve an app' do
      app_section = admin_page.apps.select {|a| a.name.text == 'App 1'}.first
      expect { app_section.make_public_link.click }.to change { admin_page.apps.count }.by(-1)
      expect(admin_page.flash_message.text).to match /Application updated/
    end
  end
end
