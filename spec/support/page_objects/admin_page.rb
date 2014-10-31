require 'site_prism'

class AdminPage < SitePrism::Page
  set_url '/admin'
  set_url_matcher(/\/admin/)

  element :flash_message, '.alert.alert-info'

  sections :apps, 'tbody tr' do
    element :name, 'td:nth-of-type(1)/a'

    element :make_public_link, "input[type='submit'][value='Make Public']"
  end
end
