class Doorkeeper::Application
  include Doorkeeper::Models::Scopes
  include ApplicationExtension

  has_and_belongs_to_many :owners, class_name: '::User',
                           join_table: 'oauth_applications_owners',
                           foreign_key: 'oauth_application_id',
                           association_foreign_key: 'owner_id'

  validate do |a|
    return if a.scopes.nil?
    unless Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(a.scopes_string.to_s, Doorkeeper.configuration.scopes)
      errors.add(:scopes, 'Invalid scope')
    end
  end

  audit_on :create
end
