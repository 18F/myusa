require 'site_prism'

class WelcomePage < SitePrism::Page
  set_url '/mobile_recovery/welcome' #TODO: naming?
  set_url_matcher(/\/mobile_recovery\/(welcome|cancel)/)

  element :heading, 'h2'
  element :welcome_text, 'h2 + p'

  element :redirect_link, "a[text()='here']"
  element :meta_refresh, :xpath, "/html/head/meta[@http-equiv='refresh']", visible: false
end
