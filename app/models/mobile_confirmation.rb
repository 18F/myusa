require 'sms_wrapper'

class MobileConfirmation < ActiveRecord::Base
  belongs_to :profile

  attr_accessor :raw_token

  before_create :generate_token
  after_save :send_raw_token

  def authenticate(raw_token)
    digested = Devise.token_generator.digest(self.class, :token, raw_token)
    #TODO: validate expiration
    if Devise.secure_compare(digested, self.token)
      self.token = nil
      self.confirmed_at = Time.now
      save!
    end
  end

  def confirmed?
    #TODO: figure out how invalidation works
    !!self.confirmed_at
  end

  def regenerate_token
    generate_token
    save
  end

  private

  def generate_token
    self.raw_token = rand.to_s[2..7]
    self.token = Devise.token_generator.digest(self.class, :token, self.raw_token)
    self.confirmation_sent_at = Time.now
  end

  def send_raw_token
    sms_message = "Your MyUSA verification code is #{self.raw_token}"
    SmsWrapper.instance.send_message(self.profile.mobile_number, sms_message)
  end

end
