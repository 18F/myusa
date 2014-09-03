
require 'feature_helper'

describe 'Sign Out' do
  let(:user) { FactoryGirl.create(:user, email: 'testy@mclogoutson.com') }

  describe 'homepage' do
    before :each do
      login(user)
      @dashboard_page = DashboardPage.new
      @dashboard_page.load
    end

    it 'returns to homepage after logout' do
      visit destroy_user_session_path
      expect(current_url).to eq root_url
    end

    describe 'signout with redirect' do
      context 'without a matching app' do
        it 'does not return to a custom page after logout' do
          visit destroy_user_session_path(continue: 'http://www.google.com/test-logout')
          expect(current_url).to eq root_url
        end
      end

      context 'with an unmatched app' do
        let(:client_app) do
          FactoryGirl.create(:application, name: 'Logout Test App',
                                           url: 'http://www.yahoo.com/url1')
        end

        before :each do
          OAuth2::Client.new(client_app.uid, client_app.secret,
                             site: 'http://www.yahoo.com') do |b|
            b.request :url_encoded
            b.adapter :rack, Rails.application
          end

          FactoryGirl.create(:access_token,
                             application: client_app,
                             resource_owner_id: user.id)

          client_app.redirect_uri = 'http://www.yahoo.com/auth/callback'
          client_app.save!
        end

        it 'returns to a custom page after logout' do
          visit destroy_user_session_path(continue: 'http://www.google.com/')
          expect(current_url).to eq root_url
        end
      end

      context 'with a matching app' do
        let(:client_app) do
          FactoryGirl.create(:application, name: 'Logout Test App',
                                           url: 'http://www.google.com/url1')
        end

        before :each do
          OAuth2::Client.new(client_app.uid, client_app.secret,
                             site: 'http://www.example.com') do |b|
            b.request :url_encoded
            b.adapter :rack, Rails.application
          end

          FactoryGirl.create(:access_token,
                             application: client_app,
                             resource_owner_id: user.id)

          client_app.redirect_uri = 'http://www.google.com/auth/callback'
          client_app.save!
        end

        it 'returns to a custom page after logout' do
          visit destroy_user_session_path(continue: 'http://www.google.com/')
          expect(current_url).to eq 'http://www.google.com/'
        end
      end
    end
  end
end
