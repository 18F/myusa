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

def login(user, opts={})
  visit stub_login_path(id: user.id)
  visit stub_two_factor_path if opts[:two_factor]
end

def second_factor
  visit stub_two_factor_path
end

def sign_in_with_email(email)
  sign_in_page = SignInPage.new
  token_instructions_page = TokenInstructionsPage.new

  sign_in_page.email.set email
  sign_in_page.submit.click

  open_email(email)
  current_email.click_link('Connect to MyUSA')
end

def submit_new_application_form(options = {})
  options = options.reverse_merge({email:'joe@citizen.org', password:'Password1'})
  fill_in 'Name', 		 with:  'Acme'
  fill_in 'Description', with: 'This is some description filler.'
  #fill_in 'Scopes', 	 with: 'profile.email'
  fill_in 'Redirect uri', with: 'urn:ietf:wg:oauth:2.0:oob'
  click_button 'Submit'
end

class SecretController < ApplicationController
  before_filter :authenticate_user!
  include RolesHelper

  def secret
    render text: 'you got me'
  end
end

class StubLoginController < ApplicationController
  def login
    sign_in :user, User.find(params[:id])
    render text: 'logged in!'
  end

  def two_factor
    warden.set_user current_user.create_sms_code, scope: :two_factor
    render text: 'two factor!'
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw do
      get 'secret' => 'secret#secret'
      get 'stub_login' => 'stub_login#login'
      get 'stub_two_factor' => 'stub_login#two_factor'
    end
  end
end
