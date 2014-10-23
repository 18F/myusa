require 'site_prism'

class NotificationSettingsPage < SitePrism::Page
  set_url '/notifications'
  set_url_matcher(/\/notifications/)

  class AppSettingSection < SitePrism::Section
    element :label, 'td:nth-of-type(1)'
    element :email_on_link, "a:nth-of-type(1)[text()='On']"
    element :email_off_link, "a[text()='Off']"
  end

  section :myusa_settings, AppSettingSection, 'table.myusa-settings tbody tr:first-of-type'

end
