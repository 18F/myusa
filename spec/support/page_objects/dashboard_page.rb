require 'site_prism'

class DashboardPage < SitePrism::Page
  set_url '/secret'
  set_url_matcher /secret/
end