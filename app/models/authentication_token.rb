class AuthenticationToken < ActiveRecord::Base
  belongs_to :user

  audit_on :create
  before_create {|t| t.sent_at = Time.now }

  default_scope -> { where(['sent_at > ?', Time.now - 2.hours]) }

  scope :expired, -> { unscoped.where(['sent_at < ?', Time.now - 2.hours]) }

  attr_accessor :raw

  def self.authenticate(user, raw)
    return nil unless user.present?
    
    digested = Devise.token_generator.digest(self, :token, raw)
    token = user.authentication_tokens.find_by_token(digested)

    if token
      user.authentication_tokens.delete_all
      token
    else
      nil
    end
  end

  def self.generate(attrs={})
    create(attrs) do |t|
      raw, enc = Devise.token_generator.generate(self, :token)
      t.raw = raw
      t.token = enc
    end
  end

end
