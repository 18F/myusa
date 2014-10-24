class UnsubscribeToken < ActiveRecord::Base
  include Concerns::Token

  belongs_to :user
  belongs_to :notification

  def self.unsubscribe(user, raw, delivery_method)
    authenticate(user, raw) do |token|
      key = "notification_settings.app_#{token.notification.app.id}.delivery_methods.#{delivery_method}"
      user.settings[key] = false
      user.save!
    end
  end
end
