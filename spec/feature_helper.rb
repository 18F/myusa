ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara'
require 'capybara/rspec'
require 'capybara/email/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
  debug: false, js_errors: true,
  phantomjs_options: ['--load-images=no', '--disk-cache=false'] )
end

Capybara.javascript_driver = :poltergeist

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

def login(user)
  token = user.set_authentication_token
  visit new_user_session_path(email: user.email, token: token.raw)
end

def submit_new_application_form(options = {})
  options = options.reverse_merge({email:'joe@citizen.org', password:'Password1'})
  fill_in 'Name', 		 with:  'Acme'
  fill_in 'Description', with: 'This is some description filler.'
  #fill_in 'Scopes', 	 with: 'profile.email'
  fill_in 'Redirect uri', with: 'urn:ietf:wg:oauth:2.0:oob'
  click_button 'Submit'
end