module TwoFactorAuthentication
  module Strategies
    class Base < Warden::Strategies::Base

      def valid?
        user_signed_in?
      end

      private

      def warden
        env['warden']
      end

      def user_signed_in?
        env['warden'].authenticated?(:user)
      end

      def current_user
        env['warden'].user(:user)
      end

    end
  end
end
