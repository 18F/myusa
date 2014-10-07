class Doorkeeper::AccessGrant
  belongs_to :resource_owner, class_name: User
  audit_on :after_create, action: 'grant'
end
