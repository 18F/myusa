
require 'site_prism'

# EditProfilePage
class ProfilePage < SitePrism::Page
  set_url '/profile'
  set_url_matcher(/\/profile/)
end
