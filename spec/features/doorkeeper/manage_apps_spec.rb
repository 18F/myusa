
require 'feature_helper'

describe 'OAuth' do
  let(:user) { FactoryGirl.create(:user, email: 'testy.mctesterson@gsa.gov') }

  let(:scopes) { 'profile.email profile.title profile.first_name ' \
  'profile.middle_name profile.last_name profile.phone_number profile.suffix ' \
  'profile.address profile.address2 profile.zip profile.gender ' \
  'profile.marital_status profile.is_parent profile.is_student ' \
  'profile.is_veteran profile.is_retired notifications' }

  let(:client_app) { FactoryGirl.create(:application, name: 'Client App 1', scopes: scopes) }
  let(:client_app2) { FactoryGirl.create(:application, name: 'Client App 2') }

  let(:requested_scopes) { 'profile.email profile.last_name notifications' }

  describe 'Authorizations' do
    let(:requested_scopes) do
      'profile.email profile.title profile.first_name profile.middle_name ' \
      'profile.last_name profile.phone_number profile.suffix profile.address ' \
      'profile.address2 profile.zip profile.gender profile.marital_status ' \
      'profile.is_parent profile.is_student profile.is_veteran ' \
      'profile.is_retired notifications'
    end

    let(:client_application_scopes2) do
      'profile.email profile.phone_number profile.zip profile.gender ' \
      'profile.is_parent profile.is_student profile.is_veteran notifications'
    end

    let(:requested_scopes2) do
      'profile.email profile.phone_number profile.zip profile.gender ' \
      'notifications'
    end

    let(:client_app2) do
      FactoryGirl.create(:application, name: 'Client App 2',
                                       scopes: client_application_scopes2)
    end

    before :each do
      @auths_page = OAuth2::AuthorizationsPage.new
    end

    context 'when logged in' do
      before :each do
        FactoryGirl.create(:access_token, resource_owner: user, application: client_app, scopes: requested_scopes)
        FactoryGirl.create(:access_token, resource_owner: user, application: client_app2, scopes: requested_scopes2)

        login user
        @auths_page.load
      end

      it 'displays the authorizations' do
        expect(@auths_page).to be_displayed
        expect(@auths_page.authorizations.first.app_name).to have_content 'Client App 1'
        expect(@auths_page.authorizations.second.app_name).to have_content 'Client App 2'
        expect(@auths_page.authorizations.first.app_scopes.map(&:text)).to eq(
          ['Email Address', 'Title', 'First Name', 'Middle Name', 'Last Name',
           'Suffix', 'Home Address', 'Home Address (Line 2)', 'Zip Code',
           'Phone Number', 'Gender', 'Marital Status', 'Are you a Parent?',
           'Are you a Student?', 'Are you a Veteran?', 'Are you Retired?'])
        expect(@auths_page.authorizations.first.app_scope_sections.map(&:text)).to eq(
          ['Identify you by your email address',
           'Address you by name',
           'Know where you live',
           'Know how to contact you by phone or text message',
           'Find out more about you',
           'Send you notifications via MyUSA'])
        expect(@auths_page.authorizations.second.app_scopes.map(&:text)).to eq(
          ['Email Address', 'Zip Code', 'Phone Number', 'Gender'])
        expect(@auths_page.authorizations.second.app_scope_sections.map(&:text)).to eq(
          ['Identify you by your email address',
           'Know where you live',
           'Know how to contact you by phone or text message',
           'Find out more about you',
           'Send you notifications via MyUSA'])
      end

      it 'revokes authorization to an application' do
        expect(@auths_page).to be_displayed
        expect(@auths_page.authorizations.second.app_name).to have_content 'Client App 2'
        @auths_page.authorizations.second.revoke_access_button.click
        expect(@auths_page).to be_displayed
        expect(@auths_page.authorizations.first.app_name).to have_content 'Client App 1'
        expect(@auths_page).to_not have_content 'Client App 2'
      end
    end
  end

  describe 'applications' do
    before :each do
      login user
      @new_application_page = NewApplicationPage.new
      @edit_application_page = EditApplicationPage.new
      @auths_page = OAuth2::AuthorizationsPage.new
      @new_application_page.load
      @new_application_page.name.set 'testApp'
      @new_application_page.redirect_uri.set 'urn:ietf:wg:oauth:2.0:oob'
      @new_application_page.check('First Name')
      expect(@new_application_page).to have_content(
        'Please provide '\
        'a secure (https) URL for an image that identifies your application.'\
        ' The image should be 120px by 120px in size.'
      )
      @new_application_page.submit.click
    end

    it "allows user to create app and get secret" do
      expect(@auths_page).to be_displayed
      expect(@auths_page.secret_key).to be_present
    end

    it "allows user to generate new api key" do
      old_secret = @auths_page.secret_key.text
      @auths_page.new_api_key.click
      expect(@auths_page.secret_key).to_not match(old_secret)
    end

    it 'displays private status' do
      expect(@auths_page.developer_apps.first.status).to eq('Private')
    end

    it 'allows a user to request public access' do
      @auths_page.developer_apps.first.request_public.click
      expect(@auths_page.developer_apps.first.status).to eq('Pending Approval')
      expect(ActionMailer::Base.deliveries.last.subject).to eq(
        'testApp has requested to become public'
      )
    end

    it 'displays public status' do
      app = Doorkeeper::Application.find_by_name('testApp')
      app.public = true
      app.save
      @auths_page.load
      expect(@auths_page.developer_apps.first.status).to eq('Public')
    end

    it 'can navigate to the edit page' do
      @auths_page.developer_apps.first.name.click
      expect(@edit_application_page).to be_displayed
    end
  end
end
