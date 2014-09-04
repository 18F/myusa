
require 'site_prism'

module OAuth2
  class AuthorizedApp < SitePrism::Section
    elements :app_titles, '.panel-title'
    elements :app_scopes, '.col-md-3 label'

    def app_name
      app_titles[0]
    end
  end

  # OAuth2::AuthorizationsPage
  class AuthorizationsPage < SitePrism::Page
    set_url '/oauth/applications'
    set_url_matcher(%r{/oauth/applications})

    element :secret_key,      '#secret-key'

    sections :apps, AuthorizedApp, '.panel'

    def first_app
      apps[0]
    end

    def second_app
      apps[1]
    end
  end
end
