require 'site_prism'

class OAuth2::NewApplicationPage < SitePrism::Page
  set_url '/applications/new'
  set_url_matcher(%r{/applications/new})

  element :submit,        'input[type="submit"][value="Save Application"]'
  element :name,          '#application_name'
  element :redirect_uri,  '#application_redirect_uri'
end
