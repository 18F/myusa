class Doorkeeper::Application
  include Doorkeeper::Models::Scopes
  include ApplicationExtension

  has_many :memberships, foreign_key: 'oauth_application_id'
  has_many :members, through: :memberships, source: :user

  has_many :owners, -> { where 'memberships.member_type' => 'owner' }, through: :memberships, source: :user
  has_many :developers, -> { where 'memberships.member_type' => 'developer' }, through: :memberships, source: :user

  validate do |a|
    return if a.scopes.nil?
    unless Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(a.scopes_string.to_s, Doorkeeper.configuration.scopes)
      errors.add(:scopes, 'Invalid scope')
    end
  end

  audit_on :create
end
