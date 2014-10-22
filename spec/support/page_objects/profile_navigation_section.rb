require 'site_prism'

class ProfileNavigationSection < SitePrism::Section
  element :admin_link, "a[text()='Administration']"
end

module ProfileNavigationElements
  def self.included(base)
    base.section :profile_navigation, ProfileNavigationSection, 'nav.nav#nav'
  end
end
