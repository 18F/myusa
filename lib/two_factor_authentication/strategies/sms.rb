require 'two_factor_authentication/strategies/base'

module TwoFactorAuthentication
  module Strategies
    class Sms < Base
      def valid?
        super && authentication_code.present?
      end

      def authenticate!
        if current_user.sms_code.present? &&
           current_user.sms_code.authenticate(authentication_code)

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
