class Feedback < ActiveRecord::Base
  belongs_to :user

  validate :rate_limit_per_5_seconds, on: :create
  validate :rate_limit_per_day, on: :create

  after_create :send_feedback

  scope :last_5_seconds, -> { where('created_at > ?', 5.seconds.ago) }
  scope :last_24_hours, -> { where('created_at > ?', 24.hours.ago) }
  scope :with_remote_ip, ->(remote_ip) { where(remote_ip: remote_ip) }

  RATE_LIMIT_PER_DAY = 20

  private

  def rate_limit_per_5_seconds
    if Feedback.with_remote_ip(remote_ip).last_5_seconds.exists?
      errors.add(:base, :rate_limit_per_5_seconds)
    end
  end

  def rate_limit_per_day
    if Feedback.with_remote_ip(remote_ip).last_24_hours.size >= RATE_LIMIT_PER_DAY
      errors.add(:base, :rate_limit_per_day)
    end
  end

  def send_feedback
    SystemMailer.contact_email(from, email, message).deliver
  end
end
