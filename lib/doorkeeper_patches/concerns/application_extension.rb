module ApplicationExtension
  extend ActiveSupport::Concern

  included do
    has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
    validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  end

  module ClassMethods
    def requested_public
      where.not(requested_public_at: nil)
    end
  end
end