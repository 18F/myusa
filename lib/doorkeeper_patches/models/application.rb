require 'simple_role'

class Doorkeeper::Application
  include Doorkeeper::Models::Scopes

  acts_as_authorization_object

  validates_format_of :logo_url, with: URI.regexp(['https']),
                                 allow_blank: true,
                                 message: 'Logo url must begin with https'

  scope :public?, -> { where public: true }
  scope :private?, -> { where public: false }

  scope :requested_public, -> { where.not(requested_public_at: nil) }

  validate do |a|
    return if a.scopes.nil?
    unless Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(a.scopes_string.to_s, Doorkeeper.configuration.scopes)
      errors.add(:scopes, 'Invalid scope')
    end
  end

  audit_on :after_create

  before_save :send_request_public_email

  def send_request_public_email
    if requested_public_at_changed?
      SystemMailer.app_public_email(self, owner).deliver
    end
  end
end
