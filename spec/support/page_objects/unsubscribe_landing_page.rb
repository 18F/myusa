require 'site_prism'

class UnsubscribeLandingPage < SitePrism::Page
  set_url '/unsubscribe'
  set_url_matcher(/\/unsubscribe\/email/)

  element :notification_settings_link, "p[text()*='your notification settings'] > a[text()='right here']"
end
