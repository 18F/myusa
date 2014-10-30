require 'site_prism'

class UnsubscribeLandingPage < SitePrism::Page
  set_url '/unsubscribe'
  set_url_matcher(/\/unsubscribe\/email/)

  element :notification_settings_link, "a[text()='MyUSA notification settings']"
end
