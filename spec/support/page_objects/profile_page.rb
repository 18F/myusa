
require 'site_prism'

# EditProfilePage
class ProfilePage < SitePrism::Page
  set_url '/profile'
  set_url_matcher(/\/profile/)

  elements :profile_properties, '.list-group-item'

  def first_name
    profile_properties[1].text.sub(/^First name\W*/, '')
  end

  def is_student
    profile_properties[17].text.sub(/^Student\W*/, '')
  end
end
