require 'devise/strategies/authenticatable'

module Devise
  module Models
    module EmailAuthenticatable
      extend ActiveSupport::Concern

      def set_authentication_token(opts={})
        token = AuthenticationToken.generate(opts.merge(user_id: self.id))
        self.send_devise_notification(:authentication_instructions, token)

        token
      end
    end
  end
end
