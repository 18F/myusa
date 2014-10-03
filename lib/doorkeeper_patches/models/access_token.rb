class Doorkeeper::AccessToken
  belongs_to :resource_owner, class_name: User
  audit_on :after_create, action: 'issue'
  audit_on :after_update, action: 'revoke', if: -> { revoked_at_changed? && revoked_at_was.nil? }
end
