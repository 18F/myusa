class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  validates_presence_of :subject, :received_at, :user_id
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
  
  def deliver_notification
    # NotificationMailer.notification_email(self.id).deliver
  end
end
