require 'site_prism'

class MobileConfirmationPage < SitePrism::Page
  set_url '/mobile_recovery/new' #TODO: naming?
  set_url_matcher(/\/mobile_recovery/)

  element :heading, 'h2'

  element :submit, "input.btn-primary[type='submit']"
  element :skip, "a[text()='Skip this Step']"
  element :resend, "a[text()='Resend Code']"

  element :mobile_number, '#user_unconfirmed_mobile_number'
  element :mobile_number_confirmation_token, '#mobile_confirmation_raw_token'

  element :redirect_link, "a[text()='here']"
  element :meta_refresh, :xpath, "/html/head/meta[@http-equiv='refresh']", visible: false

  element :flash_message, "div.alert"
  element :flash_resend_link, "div.alert a[text()='resend a code']"
  element :flash_reenter_link, "div.alert a[text()='re-enter your mobile number']"
end
