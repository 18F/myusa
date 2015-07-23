require 'site_prism'

class TwoFactor::SmsPage < SitePrism::Page
  set_url '/users/factors/sms'
  set_url_matcher(/\/users\/factors\/sms/)

  element :heading, 'h2'

  element :token, '#sms_raw_token'
  element :submit, "input.btn-primary[type='submit']"

  element :resend_link, "a[text()='Resend Code']"
end
