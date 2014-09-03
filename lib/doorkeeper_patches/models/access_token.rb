class Doorkeeper::AccessToken
  belongs_to :resource_owner, class_name: User
  # TODO: do we really want to audit these if they are only created via API
  # POST?
  audit_on :create
end
