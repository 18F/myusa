require 'site_prism'

class TwoFactor::SmsPage < SitePrism::Page
  set_url '/users/factors/sms'
  set_url_matcher(/\/users\/factors\/sms/)

  element :token, '#sms_raw_token'
  element :submit, "input.btn-primary[type='submit']"

  element :resend_link, "a[text()='Resend Code']"

  element :flash_message, "div.alert"
  element :flash_resend_link, "div.alert a[text()='resend a code']"

  def has_flash_message?(text)
    self.flash_message.text.match(text)
  end
end
