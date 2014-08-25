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
  module Strategies
    class EmailAuthenticatable < Authenticatable
      def valid?
        params.has_key?(:email) && params.has_key?(:token)
      end

      def authenticate!
        user = params[:email].present? && User.find_by_email(params[:email])

        @token = AuthenticationToken.find(params[:token])

        if validate(user) { @token.valid? && @token.user_id == user.id }
          @token.delete

          session['user_return_to'] = @token.return_to if @token.return_to.present?
          success!(user)
        else
          fail!(:invalid_token)
        end
      end

      def remember_me?
        !!@token.remember_me
      end
    end
  end
end

Warden::Strategies.add(:email_authenticatable, Devise::Strategies::EmailAuthenticatable)
