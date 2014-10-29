class UnsubscribeToken < ActiveRecord::Base
  include Concerns::Token

  belongs_to :user
  belongs_to :notification

  delegate :authorization, to: :notification

  def self.unsubscribe(user, raw, delivery_method)
    authenticate(user, raw) do |token|
      token.authorization.notification_settings['receive_email'] = false
      token.authorization.save!
    end
  end
end
