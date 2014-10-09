module Users
  module Factors
    class SmsController < ApplicationController
      before_filter :authenticate_user!
      before_filter :require_mobile_number!

      def show
        current_user.create_mobile_confirmation!
      end

      def create
        if warden.authenticate(:sms, scope: :two_factor)
          redirect_to retrieve_stored_location
        else
          render text: 'foobar'
        end
      end

      private

      def mobile_number
        @mobile_number ||= current_user.profile.mobile_number
      end

      def require_mobile_number!
        raise MissingMobileNumber if mobile_number.nil?
      end

      def retrieve_stored_location
        foo = session.delete(:two_factor_return_to)
        pp foo
        foo
      end

    end

    class MissingMobileNumber < Exception; end
  end
end
