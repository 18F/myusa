require 'sms_wrapper'

SmsWrapper.setup do |config|
  config.twilio_account_sid = Rails.application.secrets.twilio_account_sid
  config.twilio_auth_token = Rails.application.secrets.twilio_auth_token
  config.twilio_phone_number = Rails.configuration.sms_sender_number
end
