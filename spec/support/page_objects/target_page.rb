require 'site_prism'

class TargetPage < SitePrism::Page
  set_url '/profile'
  set_url_matcher /\/profile/
end
