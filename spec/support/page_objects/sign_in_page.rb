require 'site_prism'

class SignInPage < SitePrism::Page
  set_url '/users/sign_in'
  set_url_matcher /\/users\/sign_in/

  element :slogan,           	'.slogan'
  element :email, 				    '.hidden-buttons #inputEmail3'
  element :google_button,     'button', text: 'Sign In with Google'
  element :more_options,     	'.more-options'
  element :more_options_link,	'.more-options a'
  element :less_options,     	'.less-options'
  element :less_options_link,	'.less-options a'
  element :submit, 		'.hidden-buttons input[value="Sign in with MyUSA"]'
  element :alert,      '.alert'
end
