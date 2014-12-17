require 'site_prism'

require 'support/page_objects/dropdown_navigation_section'
require 'support/page_objects/profile_navigation_section'

class ProfilePage < SitePrism::Page
  set_url '/profile'
  set_url_matcher(/\/profile/)

  include DropdownNavigationElements
  include ProfileNavigationElements

  element :city, '#profile_city'
  element :submit, 		 'input[type="submit"][value="Save Information"]'
  element :delete_account_button, 'a[class="list-group-item"]', text: 'Delete Account'
end
