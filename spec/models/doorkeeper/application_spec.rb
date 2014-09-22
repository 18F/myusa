require 'rails_helper'

describe Doorkeeper::Application do
  describe 'application scopes' do
    let(:application) { FactoryGirl.build(:application) }

    context 'with valid scopes' do
      it 'is valid' do
        expect(application).to be_valid
      end
    end

    context 'with invalid scopes' do
      it 'is not valid' do
        application.scopes = 'foo bar baz'
        expect(application).not_to be_valid
      end
    end

    context 'with valid logo_url' do
      it 'is valid' do
        application.logo_url = 'https://www.example.com'
        expect(application).to be_valid
      end
    end

    context 'with invalid logo_url' do
      it 'is valid' do
        application.logo_url = 'http://www.example.com'
        expect(application).not_to be_valid
      end
    end
  end
end
