require 'rails_helper'

describe MobileConfirmation do
  let(:phone_number) { '800-555-3455' }
  let(:user) do
    FactoryGirl.create(:user).tap do |u|
      #TODO: put this in the factory ...
      u.profile.update_attributes(mobile_number: phone_number)
    end
  end

  describe '#new', sms: true do
    it 'generates a 6-digit token' do
      confirmation = user.profile.create_mobile_confirmation
      expect(confirmation.raw_token).to match(/\d{6}/)
    end

    it 'sends a text message with the raw token' do
      confirmation = user.profile.create_mobile_confirmation
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(confirmation.raw_token)
    end
  end

  describe '#authenticate' do
    it 'is true for a valid token'
    it 'is false for an invalid token'
    it 'is false for an old token'
  end

  describe '#regenerate_token', sms: true do
    it 'generates a new 6-digit token' do
      confirmation = user.profile.create_mobile_confirmation
      old_token = confirmation.raw_token
      confirmation.regenerate_token
      expect(confirmation.raw_token).to match(/\d{6}/)
      expect(confirmation.raw_token).to_not match(old_token)
    end

    it 'sends a text message with the raw token' do
      confirmation = user.profile.create_mobile_confirmation
      SmsSpec::Data.clear_messages
      confirmation.regenerate_token
      open_last_text_message_for(phone_number)
      expect(current_text_message.body).to match(confirmation.raw_token)
    end
  end

end
