class Feedback < ActiveRecord::Base
  belongs_to :user

  validate :rate_limit_per_5_seconds, on: :create
  validate :rate_limit_per_day, on: :create

  after_create :send_feedback

  scope :last_5_seconds, -> { where("date_sub(now(), interval 5 second) <= created_at") }
  scope :last_24_hours, -> { where("date_sub(now(), interval 24 hour) <= created_at") }

  RATE_LIMIT_PER_DAY = 20

  private

  def rate_limit_per_5_seconds
    if Feedback.where(remote_ip: self.remote_ip).last_5_seconds.exists?
      errors.add(:base, :rate_limit_per_5_seconds)
    end
  end

  def rate_limit_per_day
    if Feedback.where(remote_ip: self.remote_ip).last_24_hours.count >= RATE_LIMIT_PER_DAY
      errors.add(:base, :rate_limit_per_day)
    end
  end

  def send_feedback
    SystemMailer.contact_email(from, email, message).deliver
  end
end
