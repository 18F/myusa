require 'two_factor_authentication/strategies/base'

module TwoFactorAuthentication
  module Strategies
    class Sms < Base
      def valid?
        super && authentication_code.present?
      end

      def authenticate!
        if current_user.mobile_confirmation.present? &&
           current_user.mobile_confirmation.authenticate(authentication_code)

           success!(current_user)
        else
          fail!(:sms_authentication_failed)
        end
      end

      private

      def authentication_code
        params[:sms].present? && params[:sms][:raw_token]
      end
    end
  end
end

Warden::Strategies.add(:sms, TwoFactorAuthentication::Strategies::Sms)
