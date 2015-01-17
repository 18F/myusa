class Authorization < ActiveRecord::Base
  include Doorkeeper::Models::Revocable

  belongs_to :user
  belongs_to :application, class_name: 'Doorkeeper::Application'
  has_many :oauth_tokens, class_name: 'Doorkeeper::AccessToken'
  has_many :notifications

  serialize :notification_settings, JSON

  after_initialize :set_default_notification_settings

  scope :not_revoked, -> { where('revoked_at IS NULL') }

  def scopes
    oauth_tokens.map(&:scopes).inject(Doorkeeper::OAuth::Scopes.new, &:|)
  end

  private

  DEFAULT_NOTIFICATION_SETTINGS = {
    'receive_email' => true
  }

  def set_default_notification_settings
    self.notification_settings ||= DEFAULT_NOTIFICATION_SETTINGS
  end

end
