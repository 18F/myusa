
require 'site_prism'

module OAuth2
  class AuthorizedApp < SitePrism::Section
    elements :app_titles, '.panel-title'
    elements :app_scopes, '.col-md-3 label'
    elements :app_scope_sections, 'h2.open'
    element :revoke_access_button, "input[value='Revoke Access']"

    def app_name
      app_titles[0]
    end
  end

  class DeveloperApp < SitePrism::Section
    elements :app_properties, 'td'
    element :request_public, 'input[type="submit"][value="Request Public Access"]'

    def status
      app_properties[3].text
    end
  end

  # OAuth2::AuthorizationsPage
  class AuthorizationsPage < SitePrism::Page
    set_url '/oauth/applications'
    set_url_matcher(%r{/oauth/applications})

    element :secret_key,      '#secret-key'
    element :new_api_key,     'input[type="submit"][value="New API Key"]'
    sections :developer_apps, DeveloperApp, 'tbody tr'

    sections :apps, AuthorizedApp, '.panel'

    def first_app
      apps[0]
    end

    def first_revoke_button
      first_app.revoke_access_button
    end

    def second_app
      apps[1]
    end

    def second_revoke_button
      second_app.revoke_access_button
    end

    def first_developer_app
      developer_apps[0]
    end
  end
end
