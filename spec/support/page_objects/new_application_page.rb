require 'site_prism'

# NewApplicationPage
class NewApplicationPage < SitePrism::Page
  set_url '/applications/new'
  set_url_matcher(/\/applications\/new/)
  element :logo_url_hint, '#logo_url_hint'
end
