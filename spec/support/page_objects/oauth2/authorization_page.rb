require 'site_prism'

class OAuth2::AuthorizationPage < SitePrism::Page
  set_url '/oauth/authorize'
  set_url_matcher /\/oauth\/authorize/

  element :scopes, "ul"

  element :allow_button, "input[value='Allow']"
  element :cancel_button, "input[value='Cancel']"

  element :error_message, "div.page-header[contains('An error has occurred')] ~ main"
end
