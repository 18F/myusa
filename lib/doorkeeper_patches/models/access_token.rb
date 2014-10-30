class Doorkeeper::AccessToken
  belongs_to :resource_owner, class_name: User
  belongs_to :authorization
  audit_on :after_create, action: 'issue'
  audit_on :after_update, action: 'revoke', if: -> { revoked_at_changed? && revoked_at_was.nil? }

  before_create :create_authorization

  private

  def create_authorization
    self.authorization = Authorization.where(user: resource_owner, application: application).first_or_create
  end
end
