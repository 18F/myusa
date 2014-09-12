
require 'site_prism'

# DeleteAccountPage
class DeleteAccountPage < SitePrism::Page
  set_url '/profile/delete'
  set_url_matcher(%r{/profile/delete_account})

  element :enter_email, 'input#email'
  element :delete_button, 'input[type="submit"][value="Confirm ' \
    'Deletion of My Account"]'
end
