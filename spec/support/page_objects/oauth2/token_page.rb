require 'site_prism'

class OAuth2::TokenPage < SitePrism::Page
  set_url_matcher /\/oauth\/authorize\/\h{64}/

  element :code, "#authorization_code"
end
