
require 'site_prism'

module OAuth2
  # OAuth2::AuthorizationsPage
  class AuthorizationsPage < SitePrism::Page
    set_url '/oauth/authorized_applications'
    set_url_matcher(%r{/oauth/authorized_applications})

    elements :app_titles, '.panel-title'

    def first_app_title
      app_titles[0]
    end

    def second_app_title
      app_titles[3]
    end
  end
end
