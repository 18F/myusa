class Doorkeeper::Application
  include Doorkeeper::Models::Scopes

  has_many :memberships, foreign_key: 'oauth_application_id', dependent: :destroy
  has_many :members, through: :memberships, source: :user

  has_many :owners, -> { where 'memberships.member_type' => 'owner' }, through: :memberships, source: :user
  has_many :developers, -> { where 'memberships.member_type' => 'developer' }, through: :memberships, source: :user

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

  audit_on :create
end
