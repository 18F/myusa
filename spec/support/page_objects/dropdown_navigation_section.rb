class DropdownNavigationSection < SitePrism::Section
  element :profile, "ul li a[text()='Your Profile']"
  element :applications, "ul li a[text()='Your Applications']"
  element :admin, "ul li a[text()='Admin']"
end
