require 'site_prism'

class TargetPage < SitePrism::Page
  # NOTE: this is defined in feature_helper.rb, not routes.rb, and is ONLY to be
  # used for Capybara tests.
  set_url '/secret'
  set_url_matcher /\/secret/
end
