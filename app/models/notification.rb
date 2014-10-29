class Notification < ActiveRecord::Base
  belongs_to :authorization

  delegate :user, :application, to: :authorization
  alias_method :app, :application

  has_many :unsubscribe_tokens
  validates_presence_of :subject, :body #, :user_id
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

  private

  def email_notification?
    self.authorization.notification_settings['receive_email']
  end

  def deliver_notification
    if email_notification?
      token = UnsubscribeToken.generate(user: self.user, notification: self)
      NotificationMailer.notification_email(self, token).deliver
    end
  end
end
