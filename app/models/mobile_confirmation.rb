require 'sms_wrapper'

class MobileConfirmation < ActiveRecord::Base
  # TODO: remove this relation ... these should belong to users, not profiles
  belongs_to :profile

  belongs_to :user

  attr_accessor :raw_token

  before_create :generate_token
  after_save :send_raw_token

  TOKEN_EXPIRY = 30.minutes

  def authenticate(raw_token)
    return false unless confirmation_sent_at > Time.now - TOKEN_EXPIRY
    digested = Devise.token_generator.digest(self.class, :token, raw_token)
    if Devise.secure_compare(digested, self.token)
      self.token = nil
      self.confirm!
      true
    else
      UserAction.failed_authentication.create(data: { authentication_method: 'sms' })
      false
    end
  end

  def confirm!
    UserAction.successful_authentication.create(data: { authentication_method: 'sms' })
    self.confirmed_at = Time.now
    save!
  end

  def confirmed?
    !!self.confirmed_at
  end

  def regenerate_token
    generate_token
    save
  end

  private

  def mobile_number
    user.presence ?
      user.profile.mobile_number :
      profile.mobile_number
  end

  def generate_token
    self.raw_token = self.class.new_token
    self.token = Devise.token_generator.digest(self.class, :token, self.raw_token)
    self.confirmation_sent_at = Time.now
  end

  def send_raw_token
    if self.raw_token.present?
      sms_message = I18n.t(:token_message, scope: [:mobile_confirmation], raw_token: self.raw_token)
      SmsWrapper.instance.send_message(mobile_number, sms_message)
      self.raw_token = nil
    end
  end

  def self.new_token
    rand.to_s[2..7]
  end
end
