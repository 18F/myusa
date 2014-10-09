require 'site_prism'

class TwoFactorAuthentication::SmsPage < SitePrism::Page
  set_url '/users/factors/sms'
  set_url_matcher(/\/users\/factors\/sms/)

  element :token, '#sms_raw_token'
  element :submit, "input.btn-primary[type='submit']"
end
