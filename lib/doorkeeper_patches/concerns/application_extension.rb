module ApplicationExtension
  extend ActiveSupport::Concern

  included do
    validates_format_of :logo_url, with: URI.regexp(['https']), if: :logo_url?,
                                   message: 'Logo url must begin with https'
  end

  module ClassMethods
    def requested_public
      where.not(requested_public_at: nil)
    end
  end
end
