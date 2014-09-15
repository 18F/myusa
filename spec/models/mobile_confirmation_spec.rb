require 'rails_helper'

describe MobileConfirmation do
  let(:phone_number) { '800-555-3455' }
  let(:profile) { FactoryGirl.create(:profile, mobile_number: phone_number) }

  describe '#create', sms: true do
    it 'sends a 6-digit token' do
      profile.create_mobile_confirmation
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(/\d{6}/)
    end
  end

  describe '#save', sms: true do
    subject { -> { profile.mobile_confirmation.save! }}

    before :each do
      profile.create_mobile_confirmation
    end

    context 'when a raw token is present' do
      before :each do
        profile.mobile_confirmation.send(:generate_token)
      end

      it 'sends a text message with the raw token' do
        is_expected.to change { messages_for(phone_number).count }.by(1)
        open_last_text_message_for(phone_number)
        expect(current_text_message.body).to match(/\d{6}/)
      end
      it 'clears the raw token' do
        is_expected.to change { profile.mobile_confirmation.raw_token }.to(nil) 
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

    it 'is true for a valid token' do
      allow(MobileConfirmation).to receive(:new_token).and_return(raw_token)
      profile.create_mobile_confirmation
      expect(profile.mobile_confirmation.authenticate(raw_token)).to be_truthy
    end

    it 'is false for an invalid token' do
      allow(MobileConfirmation).to receive(:new_token).and_return(raw_token)
      profile.create_mobile_confirmation
      expect(profile.mobile_confirmation.authenticate('foobar')).to be_falsey
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
        allow(MobileConfirmation).to receive(:new_token).and_return(raw_token)
        confirmation = profile.create_mobile_confirmation
        Timecop.travel(date + 1.hour)
        expect(confirmation.authenticate(raw_token)).to be_falsey
      end
    end
  end

  describe '#re_generate_token', sms: true do
    it 'creates a new token' do
      confirmation = profile.create_mobile_confirmation
      old_token = confirmation.token
      confirmation.regenerate_token
      expect(confirmation.token).to_not match(old_token)
    end

    it 'sends a text message with the raw token' do
      confirmation = profile.create_mobile_confirmation
      SmsSpec::Data.clear_messages
      confirmation.regenerate_token
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(/\d{6}/)
    end
  end

end
