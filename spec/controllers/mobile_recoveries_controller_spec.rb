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

    context 'mobile number contains letters' do
      let(:phone_number) { 'call me plz' }
      it 'validates phone number format' do
        is_expected.to_not change{user.reload.unconfirmed_mobile_number}
        expect(controller.resource.errors[:unconfirmed_mobile_number]).to include("Phone numbers should only contain digits.")
      end
    end

    context 'mobile number fails Twilio validation' do
      let(:phone_number) { '94873457234905823049582039485' }
      let(:exception) { Twilio::REST::RequestError.new("The 'To' number #{phone_number} is not a valid phone number.", 21211) }
      before :each do
        allow(SmsWrapper.instance).to receive(:send_message).and_raise(exception)
      end
      it 'shows an error' do
        subject.call
        expect(controller.resource.errors[:unconfirmed_mobile_number]).to include("The phone number must be valid.")
      end
    end

    context 'Twilio returns unknown error' do
      let(:exception) { Twilio::REST::RequestError.new("Everything went bang and I'm really unhappy.", 21212) }
      before :each do
        allow(SmsWrapper.instance).to receive(:send_message).and_raise(exception)
        agent = stub_const("NewRelic::Agent", Class.new)
        allow(agent).to receive(:notice_error)
      end
      it 'shows an error' do
        subject.call
        expect(flash).to include ['alert', 'We had a problem sending you an SMS message. It looks like the problem may be on our end, so we have logged it for investigation. In the meantime it may be worth trying again. Sorry about this!']
      end
    end

  end
end
