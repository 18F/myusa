class Doorkeeper::AccessGrant
  belongs_to :resource_owner, class_name: User
  audit_on :create, action: 'grant', user: :resource_owner
end
