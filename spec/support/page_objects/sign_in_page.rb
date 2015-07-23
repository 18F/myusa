require 'site_prism'

class SignInPage < SitePrism::Page
  set_url '/users/sign_in'
  set_url_matcher %r{/users/sign_in}

  element :slogan,             '.myusa-subhead'
  element :email,              'noscript #inputEmail'
  element :google_button,      '.omniauth-buttons button', text: 'Connect with Google'
  element :remember_me,        'noscript #remember'
  element :google_signin_ui,   '.omniauth-buttons'
  element :google_signin_link, '.more-signin a.less-options'
  element :email_signin_link,  '.more-signin a.more-options'
  element :email_signin_ui,    '.email-buttons'
  element :submit,             'noscript input[value="Connect"]'
  element :alert,              '.alert'
end
