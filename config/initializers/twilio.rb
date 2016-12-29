require 'sms_wrapper'

SmsWrapper.setup do |config|
  config.twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
  config.twilio_phone_number = ENV['SMS_NUMBER']
  config.delivery_method = Rails.configuration.sms_delivery_method rescue :email
end
