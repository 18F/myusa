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
          redirect_to after_two_factor_path
        else
          flash.now[:error] = t(:bad_token, scope: [:two_factor, :sms], resend_link: new_users_factors_sms_path).html_safe
          render :show
        end
      end

      private

      #TODO: these should be shared between 2FA controllers

      def after_two_factor_path
        retrieve_stored_location || settings_account_settings_path
      end

      def retrieve_stored_location
        session.delete(:two_factor_return_to)
      end

      # Don't require two factor when the user is trying to authenticate a
      # second factor!
      def require_two_factor!; end
    end
  end
end
