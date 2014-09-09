require 'site_prism'

class MobileConfirmationPage < SitePrism::Page
  set_url '/user/recovery/new' #TODO: naming?
  set_url_matcher(/\/user\/recovery/)

  element :heading, 'h2'

  element :mobile_number, '#profile_mobile_number'
  element :submit, "input[value='Add a number']"

  element :mobile_number_confirmation_token, '#profile_confirmation_raw_token'
end
