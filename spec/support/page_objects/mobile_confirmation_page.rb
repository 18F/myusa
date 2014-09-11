require 'site_prism'

class MobileConfirmationPage < SitePrism::Page
  set_url '/mobile_recovery/new' #TODO: naming?
  set_url_matcher(/\/mobile_recovery/)

  element :heading, 'h2'

  element :submit, "input.btn-primary[type='submit']"
  element :skip, "a[text()='Skip this Step']"
  element :resend, "input.btn-default[value='Resend Code']"

  element :mobile_number, '#profile_mobile_number'
  element :mobile_number_confirmation_token, '#mobile_confirmation_raw_token'

  element :redirect_link, "a[text()='here']"
  element :meta_refresh, :xpath, "/html/head/meta[@http-equiv='refresh']", visible: false
end
