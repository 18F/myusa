module NotificationsHelper
  def notifications_enabled?(app_id, notification_method)
    setting = current_user.settings["notification_settings.app_#{app_id}.delivery_methods"]
    return setting.nil? || setting.include?(notification_method)
  end

  def notifications_toggle(app_id, notification_method)
    if notifications_enabled?(app_id, notification_method)
      link_to 'Off', notifications_unsubscribe_path(app_id, notification_method), class: 'btn btn-default'
    else
      link_to 'On', notifications_subscribe_path(app_id, notification_method), class: 'btn btn-primary'
    end
  end
end
