require 'site_prism'

class NotificationSettingsPage < SitePrism::Page
  set_url '/settings/notifications'
  set_url_matcher(/\/settings\/notifications/)

  class AppSettingSection < SitePrism::Section
    element :label, 'td:nth-of-type(1)'
    element :email_on_button, "input[value='On']"
    element :email_off_button, "input[value='Off']"
  end

  section :myusa_settings, AppSettingSection, 'table.myusa-settings tbody tr'
  sections :app_settings, AppSettingSection, 'table.application-settings tbody tr'
end
