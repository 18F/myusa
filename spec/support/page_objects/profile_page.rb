
require 'site_prism'

# EditProfilePage
class ProfilePage < SitePrism::Page
  set_url '/profile'
  set_url_matcher(/\/profile/)

  elements :profile_properties, '.list-group-item'

  def first_name
    profile_properties[1]
  end
end
