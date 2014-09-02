require 'audit_wrapper'

class Doorkeeper::AccessToken
  belongs_to :resource_owner, class_name: User
  AuditWrapper.audit_create(self, user_method: :resource_owner)
end
