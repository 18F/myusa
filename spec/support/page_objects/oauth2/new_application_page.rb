require 'site_prism'

class NewApplicationPage < SitePrism::Page
  set_url '/applications/new'
  set_url_matcher(%r{/applications/new})

  element :submit,        'input[type="submit"][value="Save Application"]'
  element :name,          '#application_name'
  element :redirect_uri,  '#application_redirect_uri'
  element :owner_emails,  '#application_owner_emails'
end

class EditApplicationPage < NewApplicationPage
  set_url '/applications/{id}/edit'
  set_url_matcher(%r{/applications/\d+/edit})
end
