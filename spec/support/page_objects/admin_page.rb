require 'site_prism'

class AdminPage < SitePrism::Page
  set_url '/admin'
  set_url_matcher(/\/admin/)

end
