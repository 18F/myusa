require 'hashie'

class AuthenticationToken # < Hashie::Dash
  attr_accessor :user_id, :raw, :token, :remember_me, :return_to

  def self.create(attrs={})
    token = new(attrs)
    if block_given?
      yield(token)
    end
    token.save && token
  end

  def self.find(raw)
    if from_cache = Rails::cache.fetch(cache_key(raw))
      new(from_cache.merge(raw: raw))
    else
      new
    end
  end

  def initialize(attrs={})
    @user_id = attrs[:user_id]
    @remember_me = attrs[:remember_me]
    @return_to = attrs[:return_to]
    @raw = attrs[:raw]
    @token = attrs[:token]
  end

  def save
    Rails::cache.write(self.class.cache_key(self.raw), serialized, expires_in: 30.minutes)
  end

  def delete
    Rails::cache.delete(self.class.cache_key(self.raw))
  end

  def self.generate(attrs={})
    create(attrs) do |t|
      t.generate_token
    end
  end

  def generate_token
    @raw = Devise.friendly_token
    @token = OpenSSL::HMAC.hexdigest('SHA256', @user_id.to_s, @raw)
  end

  def valid?
    digested = self.raw.present? && OpenSSL::HMAC.hexdigest('SHA256', @user_id.to_s, self.raw.to_s)
    Devise.secure_compare(digested, self.token)
  end

  private

  def serialized
    {
      user_id: @user_id,
      remember_me: @remember_me,
      return_to: @return_to,
      token: @token
    }
  end

  def self.cache_key(token)
    "authentication_token_#{token}"
  end
end
