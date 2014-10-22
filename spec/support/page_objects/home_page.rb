require 'site_prism'
require 'support/page_objects/dropdown_navigation_section'

class HomePage < SitePrism::Page
  set_url '/'
  set_url_matcher(/\/?$/)

  element :contact_flash, 'div.contact-flash'
  element :contact_flash_no_js, '.alert.alert-info'

  section :login_form, 'section.login-section' do
    element :email, "noscript input#inputEmail"
    element :remember_me, "noscript input#user_remember_me"
    element :submit, "noscript input[value='Connect']"
    element :google_button,     '.login button', text: 'Connect with Google'
  end

  section :contact_form, '#contact-form' do
    element :message, '#contact_us_message'
    element :from, '#contact_us_from'
    element :return_email, '#contact_us_email'
    element :submit, "input[value='Send Us Your Message']"
  end

  def submit_contact_form(message = 'lorum', email = 'user@example.com')
    load
    contact_form.message.set(message)
    contact_form.from.set(email)
    contact_form.submit.click
    wait_for_contact_flash
  end
end
