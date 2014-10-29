module NotificationsHelper
  def notification_email_form(settings)
    key = 'receive_email'
    value = settings[key]

    button_text = value ? 'On' : 'Off'
    button_class = "btn btn-" + (value ? 'primary' : 'default')

    hidden_field_tag('key', key) +
    hidden_field_tag('value', !value) +
    submit_tag(button_text, class: button_class)
  end
end
