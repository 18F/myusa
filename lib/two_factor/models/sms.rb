module TwoFactor
  module Models
    module Sms
      extend ActiveSupport::Concern

      included do
        before_validation :normalize_mobile_numbers

        validates :mobile_number, format: { with: /\A\+?\d+\z/, message: :phone_number_invalid_format }, allow_blank: true
        validates :unconfirmed_mobile_number, format: { with: /\A\+?\d+\z/, message: :phone_number_invalid_format }, allow_blank: true
      end

      def self.required_fields(klass)
        [:mobile_number, :unconfirmed_mobile_number]
      end

      def confirm_mobile_number!(number)
        if number.present? && number == unconfirmed_mobile_number
          self.mobile_number = unconfirmed_mobile_number
          self.unconfirmed_mobile_number = nil
          save!
        end
      end

      private

      def normalize_mobile_numbers
        [:mobile_number, :unconfirmed_mobile_number].each do |field|
          self[field].gsub!(/[\(\)\-\s]/, '') if attribute_present?(field)
        end
      end
    end
  end
end
