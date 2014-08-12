require 'site_prism'

class OAuth2::AuthorizationPage < SitePrism::Page
  set_url '/oauth/authorize'
  set_url_matcher /\/oauth\/authorize/

  element :scopes, ".scope-list"
  element :scope_email_checkbox, "input[value='profile.email']"

  element :allow_button, "input[value='Allow Access']"
  element :cancel_button, "input[value='No Thanks']"

  element :error_message, "div.page-header[contains('An error has occurred')] ~ main"
end
