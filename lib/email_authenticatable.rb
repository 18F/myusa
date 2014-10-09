require 'devise/strategies/authenticatable'

module Devise
  module Models
    module EmailAuthenticatable
      extend ActiveSupport::Concern

      def set_authentication_token(opts={})
        token = AuthenticationToken.generate(opts.merge(user: self))
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

        if validate(user) { @token = AuthenticationToken.authenticate(user, params[:token]) }
          session['user_return_to'] = @token.return_to if @token.return_to.present?
          success!(user)
        end
      end

      def remember_me?
        !!@token.remember_me
      end

      def success!(user)
        super
        UserAction.successful_authentication.create(user: user, data: { authentication_method: 'email' })
      end

      def fail!(*args)
        super
        UserAction.failed_authentication.create(user: user, data: { authentication_method: 'email', message: @message })
      end
    end
  end
end

Warden::Strategies.add(:email_authenticatable, Devise::Strategies::EmailAuthenticatable)
