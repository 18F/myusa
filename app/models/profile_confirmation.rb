class ProfileConfirmation < ActiveRecord::Base
  belongs_to :user
  belongs_to :profile

  attr_accessor :raw_token

  before_create :generate_token

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

  private

  def generate_token
    raw, enc = Devise.token_generator.generate(self.class, :token)
    self.raw_token = raw
    self.token = enc
    self.confirmation_sent_at = Time.now
  end

end
