require 'simple_role'

class Doorkeeper::Application
  include Doorkeeper::Models::Scopes

  acts_as_authorization_object

  validates_format_of :logo_url, with: URI.regexp(['https']),
                                 allow_blank: true,
                                 message: 'Logo url must begin with https'

  validates_acceptance_of :terms_of_service_accepted, if: :federal_agency,
                                                      accept: true,
                                                      allow_nil: false,
                                                      message: :federal_agency_tos_required,
                                                      tos_link: ->(values) { Rails.application.routes.url_helpers.legal_path(anchor: 'terms-of-service') }

  validates_presence_of :organization, if: :federal_agency,
                                       accept: true,
                                       allow_nil: false,
                                       message: :federal_agency_org_required

  before_save :clear_requested_public_at, if: ->(a) { a.public_changed? && a.public }

  scope :public?, -> { where public: true }
  scope :private?, -> { where public: false }

  scope :requested_public, -> { where.not(requested_public_at: nil) }

  scope :filter, ->(filter) {
    case filter
    when 'pending-approval'
      requested_public
    when 'all'
      nil
    else
      nil
    end
  }

  scope :search, ->(search) { search.present? && where("name like (?)", "%#{search}%") }

  validate do |a|
    return if a.scopes.nil?
    unless Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(a.scopes_string.to_s, Doorkeeper.configuration.scopes)
      errors.add(:scopes, 'Invalid scope')
    end
  end

  audit_on :after_create
  audit_on :after_update

  def request_public(user)
    if self.update_attribute(:requested_public_at, DateTime.now)
      SystemMailer.app_public_email(self, user).deliver
    end
  end

  private

  def clear_requested_public_at
    self.requested_public_at = nil
  end
end
