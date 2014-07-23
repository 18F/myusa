require 'devise/strategies/authenticatable'

module Devise
  module Models
    module EmailAuthenticatable
      extend ActiveSupport::Concern

      def set_authentication_token
        raw, enc = Devise.token_generator.generate(self.class, :authentication_token)

        self.authentication_token   = enc
        self.authentication_sent_at = Time.now.utc
        self.save!(validate: false)

        send_devise_notification(:authentication_instructions, raw, {})
        raw
      end

      def verify_authentication_token(raw_token)
        authentication_token = Devise.token_generator.digest(self, :authentication_token, raw_token)
        Devise.secure_compare(self.authentication_token, authentication_token)
      end

      def expire_authentication_token
        self.authentication_token = nil
        self.save!(validate: false)
      end
    end
  end
end
