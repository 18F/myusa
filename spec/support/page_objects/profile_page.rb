
require 'site_prism'

# EditProfilePage
class ProfilePage < SitePrism::Page
  set_url '/profile'
  set_url_matcher(/\/profile/)

  element :first_name, '#first_name'
  element :is_student, '#is_student'
end
