require 'rails_helper'

describe MobileRecoveriesController do
  let(:phone_number) { '8005553455' }
  let(:user) { FactoryGirl.create(:user) }

  before :each do
    sign_in user
  end

  describe '#create' do
    subject { -> { post :create, user: { unconfirmed_mobile_number: phone_number } } }

    context 'two factor is not configured' do
      it 'sets the user\'s unconfirmed_mobile_number' do
        is_expected.to change{user.reload.unconfirmed_mobile_number}.from(nil).to(phone_number)
      end

    end

    context 'mobile number is invalid' do
      let(:phone_number) { 'call me plz' }
      it 'validates phone number format' do
        is_expected.to_not change{user.reload.unconfirmed_mobile_number}
      end
    end
  end
end
