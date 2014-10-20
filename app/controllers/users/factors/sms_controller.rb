module Users
  module Factors
    class SmsController < ApplicationController
      before_filter :authenticate_user!
      before_filter :require_mobile_number!

      def show
        if current_user.sms_code.present?
          current_user.sms_code.regenerate_token
        else
          current_user.create_sms_code!
        end
      end

      def create
        if warden.authenticate(:sms, scope: :two_factor)
          redirect_to retrieve_stored_location
        else
          flash[:error] = t(:bad_token, scope: [:two_factor, :sms], resend_link: users_factors_sms_path).html_safe
          render :show
        end
      end

      private

      def mobile_number
        @mobile_number ||= current_user.profile.mobile_number
      end

      def require_mobile_number!
        raise MissingMobileNumber if mobile_number.nil?
      end

      #TODO: this should be shared between 2FA controllers
      def retrieve_stored_location
        session.delete(:two_factor_return_to)
      end

    end

    class MissingMobileNumber < Exception; end
  end
end
