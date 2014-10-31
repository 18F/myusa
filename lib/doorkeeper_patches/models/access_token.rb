class Doorkeeper::AccessToken
  belongs_to :resource_owner, class_name: User

  scope :not_revoked, -> { where('revoked_at IS NULL') }
  scope :not_expired, -> { where('expires_in IS NULL or DATE_ADD(created_at, INTERVAL expires_in second) > NOW()') }

  belongs_to :authorization

  audit_on :after_create, action: 'issue'
  audit_on :after_update, action: 'revoke', if: -> { revoked_at_changed? && revoked_at_was.nil? }

  after_update :revoke_authorization, if: -> { revoked_at_changed? && revoked_at_was.nil? }

  before_create :create_authorization

  private

  def create_authorization
    self.authorization = Authorization.where(user: resource_owner, application: application).first_or_create
  end

  def revoke_authorization
    self.authorization.revoke
  end

end
