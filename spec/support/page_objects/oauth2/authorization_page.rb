require 'site_prism'
class OAuth2::AuthorizationPage < SitePrism::Page
  set_url '/oauth/authorize'
  set_url_matcher /\/oauth\/authorize/
  element :scopes, '.scope-list'
  element :scope_email_checkbox, "input[value='profile.email']"
  element :allow_button, "input[value='Allow Access']"
  element :cancel_button, "a[contains('No Thanks')]"
  element :head_back_link, "p[contains('head back to')]/a:first"
  element :error_message, "div.page-header[contains('An error has occurred')] ~ main"
  element :header, 'header'
  element :footer, 'footer'
  element :sign_in_button, "#myusa-connect"
  element :settings, "#settings"
  element :private_nav, "#private-nav"
  element :public_nav, "#public-nav"
  element :ownership, "footer[contains('MyUSA is an official website of the United States Government')]"
end
