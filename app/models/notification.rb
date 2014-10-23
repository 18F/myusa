class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :app, class_name: 'Doorkeeper::Application'
  has_many :unsubscribe_tokens
  validates_presence_of :subject, :user_id
  after_create :deliver_notification

  def self.newest_first
    where(deleted_at: nil).order(received_at: :desc, id: :desc)
  end

  def self.not_viewed
    where(viewed_at: nil, deleted_at: nil)
  end

  def view!
    self.update_attribute :viewed_at, Time.now
  end

  #TODO: maybe move this somewhere?
  def notification_delivery_methods_key
    "notification_settings.app_#{self.app.id}.delivery_methods"
  end

  private

  def email_notification?
    return true unless user.settings.has_key?(notification_delivery_methods_key)
    user.settings[notification_delivery_methods_key].include?('email')
  end

  def deliver_notification
    if email_notification?
      token = UnsubscribeToken.generate(user: self.user, notification: self)
      NotificationMailer.notification_email(self, token).deliver
    end
  end
end
