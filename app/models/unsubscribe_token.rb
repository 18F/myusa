class UnsubscribeToken < ActiveRecord::Base
  include Concerns::Token

  belongs_to :user
  belongs_to :notification

  def self.unsubscribe(user, raw, delivery_method)
    authenticate(user, raw) do |token|
      user.settings["notification_settings.app_#{token.notification.app.id}.delivery_methods"] ||= []
      user.settings["notification_settings.app_#{token.notification.app.id}.delivery_methods"].delete(delivery_method)
      user.save!
    end
  end
end
