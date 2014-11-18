require 'two_factor/strategies/base'

module TwoFactor
  module Strategies
    class Sms < Base
      def valid?
        super && raw_token.present?
      end

      def authenticate!
        sms_code = current_user.sms_code
        if sms_code.present? && sms_code.authenticate(raw_token)
          success!(sms_code)
          current_user.confirm_mobile_number!
        else
          fail!(:sms_authentication_failed)
        end
      end

      private

      def raw_token
        params[:sms].present? && params[:sms][:raw_token]
      end
    end
  end
end

Warden::Strategies.add(:sms, TwoFactor::Strategies::Sms)
