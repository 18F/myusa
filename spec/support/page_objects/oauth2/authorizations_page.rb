
require 'site_prism'

module OAuth2
  # OAuth2::AuthorizationsPage
  class AuthorizationsPage < SitePrism::Page
    set_url '/oauth/authorized_applications'
    set_url_matcher(%r{/oauth/authorized_applications})

    elements :app_titles, '.panel-title'
    elements :app_scopes, '.col-md-3 label'
    elements :revoke_access_buttons, "input[value='Revoke Access']"

    def first_app_title
      app_titles[0]
    end

    def first_revoke_button
      revoke_access_buttons[0]
    end

    def second_app_title
      app_titles[3]
    end

    def second_revoke_button
      revoke_access_buttons[1]
    end
  end
end
