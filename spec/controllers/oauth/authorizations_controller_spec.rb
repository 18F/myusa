require 'rails_helper'

describe Oauth::AuthorizationsController do

  let(:user) { User.create(email: 'testy.mctesterson@example.com') }

  let(:client_application_scopes) { 'profile.email profile.first_name profile.last_name' }

  let(:client_app) do
    FactoryGirl.create(:application,
                        redirect_uri: 'http://www.example.com/auth/myusa/callback',
                        scopes: client_application_scopes)
  end

  let(:oauth_client) do
    # Set up an OAuth2::Client instance for HTTP calls that happen outside of the Capybara context.
    # More detail here: https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem
    OAuth2::Client.new(client_app.uid, client_app.secret, site: 'http://www.example.com') do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
  end

  describe "#create" do
    context "authorization" do
      let(:raw_token) { 'unique token' }
      let(:requested_scope) { nil }
      let(:profile) { nil }

      before :each do
        allow(Doorkeeper::OAuth::Helpers::UniqueToken).to receive(:generate) { raw_token }
      end

      before :each do
        sign_in user

        post :create, {
          client_id: client_app.uid,
          redirect_uri: client_app.redirect_uri,
          state: 'state',
          response_type: 'code',
          scope: requested_scope,
          profile: profile
        }.compact
      end

      shared_examples 'oauth' do
        it 'creates grant for user' do
          token = Doorkeeper::AccessGrant.authenticate(raw_token)
          expect(token).to_not be_expired
        end
      end

      context 'with string style scopes and no profile' do
        let(:requested_scope) { %q(profile.email profile.first_name profile.last_name) }
        it_behaves_like 'oauth'
      end

      context 'with array style scopes and no profile' do
        let(:requested_scope) { %w(profile.email profile.first_name profile.last_name) }
        it_behaves_like 'oauth'
      end

      context 'with profile' do
        let(:requested_scope) { %w(profile.email profile.first_name profile.last_name) }
        let(:profile) { { last_name: 'McTesterson' } }
        it_behaves_like 'oauth'

        it 'updates profile fields' do
          expect(user.profile.reload.last_name).to eq('McTesterson')
        end
      end
    end

  end
end
