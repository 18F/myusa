require 'site_prism'

class TokenInstructionsPage < SitePrism::Page
  set_url '/users/sign_in'
  set_url_matcher %r{/users/sign_in}
end
