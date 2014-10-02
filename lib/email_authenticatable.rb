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
          log_success(user)
          success!(user)
        else
          log_failure(user)
          fail!(:invalid_token)
        end
      end

      def remember_me?
        !!@token.remember_me
      end

      def log_success(user)
        ::UserAction.create(
          action: 'successful_authentication',
          user: user,
          data: { 'authentication_method' => 'email' }
        )
      end

      def log_failure(user)
        ::UserAction.create(
          action: 'failed_authentication',
          user: user,
          data: { 'email' => params[:email], 'authentication_method' => 'email' }
        )
      end
    end
  end
end

Warden::Strategies.add(:email_authenticatable, Devise::Strategies::EmailAuthenticatable)
