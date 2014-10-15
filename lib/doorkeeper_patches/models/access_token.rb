class Doorkeeper::AccessToken
  belongs_to :resource_owner, class_name: User

  scope :not_revoked, -> { where('revoked_at IS NULL') }
  scope :not_expired, -> { where('expires_in IS NULL or DATE_ADD(created_at, INTERVAL expires_in second) > NOW()') }

  audit_on :after_create, action: 'issue'
  audit_on :after_update, action: 'revoke', if: -> { revoked_at_changed? && revoked_at_was.nil? }
end
