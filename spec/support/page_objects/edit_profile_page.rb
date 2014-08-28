
require 'site_prism'

# EditProfilePage
class EditProfilePage < SitePrism::Page
  set_url '/profile/edit'
  set_url_matcher(/\/profile\/edit/)

  element :first_name, '#profile_first_name'
  element :submit, 		 'input[type="submit"][value="Update Profile"]'
  element :is_student, '#profile_is_student'
end
