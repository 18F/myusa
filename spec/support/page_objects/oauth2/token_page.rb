require 'site_prism'

class OAuth2::TokenPage < SitePrism::Page
  set_url_matcher /\/oauth\/authorize\/\h{64}/

  element :code, "#authorization_code"

  def get_token(client, redirect_uri)
    client.auth_code.get_token(self.code.text, redirect_uri: redirect_uri)
  end
end
