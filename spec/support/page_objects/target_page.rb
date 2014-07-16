require 'site_prism'

class TargetPage < SitePrism::Page
  set_url '/secret'
  set_url_matcher /\/secret/
end
