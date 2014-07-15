require 'devise/strategies/authenticatable'

module Devise
  module Models
    module EmailAuthenticatable
      extend ActiveSupport::Concern

      def set_authentication_token
        raw, enc = Devise.token_generator.generate(self.class, :authentication_token)

        self.authentication_token   = enc
        self.authentication_sent_at = Time.now.utc
        self.save(validate: false)
        raw
      end

    end
  end
end
