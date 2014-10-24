module NotificationsHelper
  def notification_delivery_methods_form(app_id, delivery_method)
    key = "notification_settings.app_#{app_id}.delivery_methods.#{delivery_method}"
    value = current_user.settings[key].nil? || current_user.settings[key]

    button_text = value ? 'On' : 'Off'
    button_class = "btn btn-" + (value ? 'primary' : 'default')

    form_tag(settings_path) do
      hidden_field_tag('key', key) +
      hidden_field_tag('value', !value) +
      submit_tag(button_text, class: button_class)
    end
  end
end
