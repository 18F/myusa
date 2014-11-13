require 'site_prism'

class AccountSettingsPage < SitePrism::Page
  set_url '/settings/account_settings'
  set_url_matcher /\/settings\/account_settings/

  section :delete_account, 'div.delete-account' do
    element :email, 'input#email'
    element :submit, 'input[type="submit"][value="Confirm Deletion of My Account"]'
  end
end
