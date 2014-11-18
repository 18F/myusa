require 'rails_helper'

describe SmsCode do
  let(:phone_number) { '800-555-3455' }
  let(:user) { FactoryGirl.create(:user, mobile_number: phone_number) }

  describe '#create', sms: true do
    it 'sends a 6-digit token' do
      user.create_sms_code(mobile_number: user.mobile_number)
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(/\d{6}/)
    end
  end

  describe '#save', sms: true do
    let(:sms_code) { user.sms_code }
    subject { -> { sms_code.save! }}

    before :each do
      user.create_sms_code(mobile_number: user.mobile_number)
    end

    context 'when a raw token is present' do
      before :each do
        sms_code.send(:generate_token)
      end

      it 'sends a text message with the raw token' do
        is_expected.to change { messages_for(phone_number).count }.by(1)
        open_last_text_message_for(phone_number)
        expect(current_text_message.body).to match(/\d{6}/)
      end
      it 'clears the raw token' do
        is_expected.to change { sms_code.raw_token }.to(nil)
      end
    end
    context 'when raw token is not present' do
      it 'does not send a text message' do
        is_expected.to_not change { messages_for(phone_number).count }
      end
    end
  end

  describe '#authenticate' do
    let(:raw_token) { 'token' }
    let(:sms_code) { user.sms_code }

    before :each do
      allow(SmsCode).to receive(:new_token).and_return(raw_token)
      user.create_sms_code(mobile_number: user.mobile_number)
    end

    it 'is true for a valid token' do
      expect(sms_code.authenticate(raw_token)).to be_truthy
    end

    it 'is false for an invalid token' do
      expect(sms_code.authenticate('foobar')).to be_falsey
    end

    context 'when token is old' do
      let(:date) { Date.new(1999, 12, 31) }

      before :each do
        Timecop.freeze(date)
      end

      after :each do
        Timecop.return
      end

      it 'is false' do
        sms_code.regenerate_token
        Timecop.travel(date + 1.hour)
        expect(sms_code.authenticate(raw_token)).to be_falsey
      end
    end
  end

  describe '#'

  describe '#re_generate_token', sms: true do
    let(:sms_code) { user.create_sms_code(mobile_number: user.mobile_number) }

    it 'creates a new token' do
      old_token = sms_code.token
      sms_code.regenerate_token
      expect(sms_code.token).to_not match(old_token)
    end

    it 'sends a text message with the raw token' do
      SmsSpec::Data.clear_messages
      sms_code.regenerate_token
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(/\d{6}/)
    end
  end

end
