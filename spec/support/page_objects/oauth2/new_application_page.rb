require 'site_prism'

class OAuth2::NewApplicationPage < SitePrism::Page
  set_url '/oauth/applications/new'
  set_url_matcher(%r{/oauth/applications/new})

  element :submit, 		 		'input[type="submit"][value="Submit"]'
  element :name, 				'#application_name'
  element :redirect_uri,		'#application_redirect_uri'
end
