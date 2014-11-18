module Users
  module Factors
    class SmsController < ApplicationController
      before_filter :authenticate_user!

      def new
        if current_user.sms_code.present?
          current_user.sms_code.regenerate_token
        end
        render :show
      end

      def create
        if warden.authenticate(:sms, scope: :two_factor)
          redirect_to retrieve_stored_location
        else
          flash.now[:error] = t(:bad_token, scope: [:two_factor, :sms], resend_link: new_users_factors_sms_path).html_safe
          render :show
        end
      end

      private

      #TODO: this should be shared between 2FA controllers
      def retrieve_stored_location
        session.delete(:two_factor_return_to)
      end

    end
  end
end
