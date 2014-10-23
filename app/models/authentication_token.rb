class AuthenticationToken < ActiveRecord::Base
  include Concerns::Token

  belongs_to :user

  audit_on :after_create

  default_scope -> { where(['created_at > ?', Time.now - 2.hours]) }
  scope :expired, -> { unscoped.where(['created_at < ?', Time.now - 2.hours]) }

  def self.authenticate(user, raw)
    super do
      user.authentication_tokens.delete_all
    end
  end
end
