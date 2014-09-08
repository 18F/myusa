require 'site_prism'

class HomePage < SitePrism::Page
  set_url '/'
  set_url_matcher(/\/?$/)

  element :contact_flash, 'div.contact-flash'

  section :contact_form, '#contact-form' do
    element :message, '#contact_us_message'
    element :from, '#contact_us_from'
    element :return_email, '#contact_us_email'
    element :submit, "input[value='Send Us Your Message']"
  end
end
