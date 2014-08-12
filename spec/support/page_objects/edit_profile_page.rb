require 'site_prism'

class EditProfilePage < SitePrism::Page
  set_url '/profile/edit'
  set_url_matcher /\/profile\/edit/

  element :first_name, '#profile_last_name'
  element :submit, 		 'input[type="submit"][value="Update Profile"]'
end
