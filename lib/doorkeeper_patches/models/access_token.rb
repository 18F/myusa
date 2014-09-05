class Doorkeeper::AccessToken
  belongs_to :resource_owner, class_name: User
  audit_on :create, action: 'issue'
end
