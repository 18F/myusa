class UnsubscribeToken < ActiveRecord::Base
  include Concerns::Token

  belongs_to :user
  belongs_to :notification

  def self.unsubscribe(user, raw)
    authenticate(user, raw) do |token|
      user.settings["notification_settings.app_#{token.notification.app.id}.delivery_methods"] = []
      user.save!
    end
  end
end
