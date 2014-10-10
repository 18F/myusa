
require 'site_prism'

# EditProfilePage
class ProfilePage < SitePrism::Page
  set_url '/profile'
  set_url_matcher(/\/profile/)

  include DropdownNavigationElements
  include ProfileNavigationElements

  element :first_name, '#profile_first_name'
  element :delete_account_button, 'a[class="list-group-item"]', text: 'Delete Account'
end
