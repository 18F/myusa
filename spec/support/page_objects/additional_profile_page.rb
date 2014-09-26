
require 'site_prism'

# AdditionalProfilePage
class AdditionalProfilePage < SitePrism::Page
  set_url '/profile/additional'
  set_url_matcher(/\/profile\/additional/)

  element :submit,     'input[type="submit"][value="Save Information"]'
  element :is_student, '#profile_is_student'
end
