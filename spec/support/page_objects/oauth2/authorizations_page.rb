
require 'site_prism'

module OAuth2
  # OAuth2::AuthorizationsPage
  class AuthorizationsPage < SitePrism::Page
    set_url '/oauth/authorized_applications'
    set_url_matcher(%r{/oauth/authorized_applications})
  end
end
