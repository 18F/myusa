class Doorkeeper::AccessToken
  belongs_to :resource_owner, class_name: User
  audit_on :create, action: 'issue'
  audit_on :update, action: 'revoke', if: -> { revoked_at_changed? && revoked_at_was.nil? }
end
