require 'site_prism'

class SignInPage < SitePrism::Page
  set_url '/users/sign_in'
  set_url_matcher /\/users\/sign_in/

  element :slogan,           	'.login h2.text-center'
  element :email, 				    '.login .hidden-buttons #inputEmail'
  element :google_button,     '.login button', text: 'Connect with Google'
  element :remember_me,       '.login .hidden-buttons #user_remember_me'
  element :more_options,     	'.login .more-options'
  element :more_options_link,	'.login .more-options a'
  element :less_options,     	'.login .less-options'
  element :less_options_link,	'.login .less-options a'
  element :submit, 		'.login .hidden-buttons input[value="Connect"]'
  element :alert,      '.alert'
end
