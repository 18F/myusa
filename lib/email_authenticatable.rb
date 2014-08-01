require 'devise/strategies/authenticatable'

module Devise
  module Models
    module EmailAuthenticatable
      extend ActiveSupport::Concern

      def set_authentication_token(opts={})
        raw, enc = Devise.token_generator.generate(self.class, :authentication_token)

        self.authentication_token   = enc
        self.authentication_sent_at = Time.now.utc
        self.save!(validate: false)

        if opts[:remember_me] && respond_to?(:remember_me!)
          self.remember_me!
        end

        self.send_devise_notification(:authentication_instructions, raw, opts)

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

      def authentication_token_expired?
        self.authentication_sent_at && self.authentication_sent_at < 30.minutes.ago
      end

    end
  end
end
