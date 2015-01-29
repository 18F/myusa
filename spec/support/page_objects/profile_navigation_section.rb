require 'site_prism'

class ProfileNavigationSection < SitePrism::Section
  element :admin_applications_link, "a[text()='Applications']"
end

module ProfileNavigationElements
  def self.included(base)
    base.section :profile_navigation, ProfileNavigationSection, 'nav.nav#nav'
  end
end
