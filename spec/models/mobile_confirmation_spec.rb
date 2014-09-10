require 'rails_helper'

describe MobileConfirmation do
  let(:phone_number) { '800-555-3455' }
  let(:user) do
    FactoryGirl.create(:user).tap do |u|
      #TODO: put this in the factory ...
      u.profile.update_attributes(mobile_number: phone_number)
    end
  end

  describe '#create', sms: true do
    it 'sends a 6-digit token' do
      confirmation = user.profile.create_mobile_confirmation
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(/\d{6}/)
    end
  end

  describe '#save', sms: true do
    before :each do
      @confirmation = user.profile.create_mobile_confirmation
      SmsSpec::Data.clear_messages
    end

    context 'when a raw token is present' do
      it 'sends a text message with the raw token' do
        @confirmation.send(:generate_token)
        @confirmation.save!
        expect(messages_for(phone_number)).to_not be_empty
        open_last_text_message_for(phone_number)
        expect(current_text_message.body).to match(/\d{6}/)
      end
      it 'clears the raw token' do
        @confirmation.send(:generate_token)
        @confirmation.save!
        expect(@confirmation.raw_token).to be_nil
      end
    end
    context 'when raw token is not present' do
      it 'does not send a text message' do
        expect(messages_for(phone_number)).to be_empty

        @confirmation.confirm!
        expect(messages_for(phone_number)).to be_empty
      end
    end
  end

  describe '#authenticate' do
    it 'is true for a valid token'
    it 'is false for an invalid token'
    it 'is false for an old token'
  end

  describe '#generate_token', sms: true do
    it 'creates a new token' do
      confirmation = user.profile.create_mobile_confirmation
      old_token = confirmation.token

      confirmation.regenerate_token
      expect(confirmation.token).to_not match(old_token)
    end

    it 'sends a text message with the raw token' do
      confirmation = user.profile.create_mobile_confirmation
      SmsSpec::Data.clear_messages
      confirmation.regenerate_token
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(/\d{6}/)
    end
  end

end
