require 'spec_helper'

module Doorkeeper::OAuth
  describe PreAuthorization do
    let(:server) { Doorkeeper.configuration }

    let(:client_app) { FactoryGirl.create(:application, public: true, owners: [user]) }
    let(:client) do
      c = double(:client,
        redirect_uri: 'http://www.example.com',
        application: client_app
      )
      allow(c).to receive(:valid_for?).and_return(true)
      c
    end

    let(:user) { FactoryGirl.create(:user) }

    let(:scopes) { 'profile.email' }

    let(:attributes) do
      {
        response_type: 'code',
        redirect_uri: 'http://www.example.com',
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

  end
end
