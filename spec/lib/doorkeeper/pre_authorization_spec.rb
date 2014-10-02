require 'spec_helper'

module Doorkeeper::OAuth
  describe PreAuthorization do
    let(:server) { Doorkeeper.configuration }

    let(:client_app) { FactoryGirl.create(:application, public: true, owner: owner) }
    let(:client) { Doorkeeper::OAuth::Client.new(client_app) }

    let(:owner) { FactoryGirl.create(:user) }
    let(:user) { FactoryGirl.create(:user) }

    let(:scopes) { 'profile.email' }

    let(:attributes) do
      {
        response_type: 'code',
        redirect_uri: client_app.redirect_uri,
        state: 'save-this',
        scope: scopes
      }
    end

    subject do
      PreAuthorization.new(server, client, user, attributes)
    end

    context 'when there are no scopes' do
      it 'is valid' do
        expect(subject).to be_authorizable
      end
    end

    context 'when scopes are present' do
      let(:scopes) { 'profile.email profile.first_name' }

      context 'and invalid for application' do
        let(:client_app) { FactoryGirl.create(:application, scopes: 'profile.city') }
        it 'is invalid' do
          expect(subject).to_not be_authorizable
        end
      end

      context 'and valid for application' do
        let(:client_app) { FactoryGirl.create(:application, scopes: 'profile.email profile.first_name profile.last_name') }
        it 'is valid' do
          expect(subject).to be_authorizable
        end
      end
    end

    context 'app is public' do
      it 'is valid' do
        expect(subject).to be_authorizable
      end
    end
    context 'app is private' do
      let(:client_app) { FactoryGirl.create(:application, public: false, owner: owner) }
      context 'user is owner' do
        let(:user) { owner }
        it 'is valid' do
          expect(subject).to be_authorizable
        end
      end
      context 'user is developer' do
        let(:client_app) { FactoryGirl.create(:application, public: false, owner: owner, developer_emails: user.email) }
        it 'is valid' do
          expect(subject).to be_authorizable
        end
      end
      context 'user is neither owner nor developer' do
        it 'is not valid' do
          expect(subject).to_not be_authorizable
        end
      end

    end

  end
end
