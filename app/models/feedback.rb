class Feedback < ActiveRecord::Base
  validate :rate_limit_per_5_seconds, on: :create
  validate :rate_limit_per_day, on: :create

  scope :last_5_seconds, -> { where("date_sub(now(), interval 5 second) <= created_at") }
  scope :last_24_hours, -> { where("date_sub(now(), interval 24 hour) <= created_at") }

  private

  def rate_limit_per_5_seconds
    if Feedback.where(remote_ip: self.remote_ip).last_5_seconds.exists?
      errors.add(:base, 'errp') #:rate_limit_per_5_seconds)
    end
  end

  def rate_limit_per_day
    if Feedback.where(remote_ip: self.remote_ip).last_24_hours.count >= 10
      errors.add(:base, 'errp') #:rate_limit_per_day)
    end
  end
end
