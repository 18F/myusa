class AuthenticationToken < ActiveRecord::Base
  belongs_to :user

  attr_accessor :raw

  def self.authenticate(user, raw)
    digested = Devise.token_generator.digest(self, :token, raw)
    if token = AuthenticationToken.where(user: user, token: digested).first
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
