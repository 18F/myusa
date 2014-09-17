class SmsWrapper
  include Singleton

  cattr_accessor :twilio_account_sid
  @@twilio_account_sid = 'id'

  cattr_accessor :twilio_auth_token
  @@twilio_auth_token = 'secret'

  cattr_accessor :twilio_phone_number
  @@twilio_phone_number = nil


  def self.setup
    yield self
  end

  def initialize
    @@twilio_client ||= Twilio::REST::Client.new(@@twilio_account_sid, @@twilio_auth_token)
  end

  def send_message(phone_number, body)
    @@twilio_client.account.sms.messages.create(
      from: @@twilio_phone_number,
      to: normalize_phone_number(phone_number),
      body: body
    )
  end

  private

  def normalize_phone_number(number)
    stripped = number.gsub(/[- \(\)]/, '')
    if stripped.starts_with?('+')
      stripped
    elsif stripped.starts_with?('1')
      "+#{stripped}"
    else
      "+1#{stripped}"
    end
  end
end
