require 'active_support/concern'

module Concerns::Token
  extend ActiveSupport::Concern

  attr_accessor :raw

  module ClassMethods
    def authenticate(user, raw)
      return nil unless user.present?

      digested = Devise.token_generator.digest(self, :token, raw)
      token = self.where(user: user).find_by_token(digested)

      if token
        yield(token) if block_given?
        token
      else
        nil
      end
    end

    def generate(attrs={})
      create(attrs) do |t|
        raw, enc = Devise.token_generator.generate(self, :token)
        t.raw = raw
        t.token = enc
      end
    end
  end
end
