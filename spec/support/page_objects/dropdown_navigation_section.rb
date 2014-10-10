require 'site_prism'

class DropdownNavigationSection < SitePrism::Section
  element :profile_link, "ul li a[text()='Your Profile']"
  element :applications_link, "ul li a[text()='Your Applications']"
  element :admin_link, "ul li a[text()='Administration']"
end

module DropdownNavigationElements
  def self.included(base)
    base.element :dropdown_navigation_toggle, 'div.header-signedin.dropdown'
    base.section :dropdown_navigation, DropdownNavigationSection, 'div.header-signedin.dropdown'
  end
end
