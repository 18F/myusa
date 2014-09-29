
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
    element :name, 'td:nth-of-type(1)/a'

    def status
      app_properties[1].text
    end
  end

  class AuthorizationsPage < SitePrism::Page
    set_url '/authorizations'
    set_url_matcher(/\/authorizations/)

    element :secret_key,      '#secret-key'
    element :new_api_key,     'input[type="submit"][value="New API Key"]'
    sections :developer_apps, DeveloperApp, 'tbody tr'
    sections :authorizations, AuthorizedApp, '.panel'
  end
end
