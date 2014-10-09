require 'site_prism'

class AdminPage < SitePrism::Page
  set_url '/admin/test'
  set_url_matcher(/\/admin\/test/)
end
