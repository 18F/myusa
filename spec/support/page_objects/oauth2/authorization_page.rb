require 'site_prism'
class OAuth2::AuthorizationPage < SitePrism::Page
  set_url '/oauth/authorize'
  set_url_matcher /\/oauth\/authorize/

  element :scope_list, '.scope-list'
  elements :scopes, '.scope-list label'

  element :profile_email_checkbox, "input[value='profile.email']"
  element :profile_email, "input#profile_email"
  element :profile_last_name, "input#profile_last_name"
  element :profile_phone_number, "input#profile_phone_number"
  element :profile_city, "input#profile_city"

  element :allow_button, "input[value='Allow Access']"
  element :cancel_button, "a[contains('No Thanks')]"

  element :head_back_link, "p[contains('head back to')]/a:first"
  element :error_message, "div.page-header[contains('An error has occurred')] ~ main"

  element :flash_error_message, "div.alert.alert-danger"
  element :oauth_error_message, "div.page-header[contains('An error has occurred')] ~ main"

  element :header, 'header'
  element :footer, 'footer'
  element :sign_in_button, "#myusa-connect"
  element :settings, "#user-settings"
  element :ownership, "footer[contains('MyUSA is an official website of the United States Government')]"
  element :not_me_link, "a[contains('This is not me')]"
end
