require 'site_prism'

class SignInPage < SitePrism::Page
  set_url '/users/sign_in'
  set_url_matcher /\/users\/sign_in/

  element :slogan,           	'.slogan'
  element :email, 				    '.hidden-buttons #inputEmail3'
  element :google_button,     'button', text: 'Connect with Google'
  element :remember_me,       '.hidden-buttons #user_remember_me'
  element :more_options,     	'.more-options'
  element :more_options_link,	'.more-options a'
  element :less_options,     	'.less-options'
  element :less_options_link,	'.less-options a'
  element :submit, 		'.hidden-buttons input[value="Connect"]'
  element :alert,      '.alert'
end
