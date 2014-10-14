require 'rails_helper'

describe MobileRecoveriesController do
  let(:phone_number) { '800-555-3455' }
  let(:user) { FactoryGirl.create(:user) }

  before :each do
    sign_in user
  end

  describe '#create' do
    before :each do
      post :create, profile: { mobile_number: phone_number }
      user.profile.reload
    end

    it 'sets the profile mobile number' do
      expect(user.profile.mobile_number).to match(phone_number)
    end
    context 'mobile number is invalid' do
      let(:phone_number) { 'call me plz' }
      it 'validates phone number format' do
        expect(user.profile.mobile_number).to be_nil
        expect(flash[:error]).to be
      end
    end
  end
end
