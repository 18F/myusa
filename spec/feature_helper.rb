ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require 'simplecov'
SimpleCov.start 'rails'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara'
require 'capybara/rspec'
require 'capybara/poltergeist'
Capybara.default_driver = :poltergeist

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
  debug: false, js_errors: true,
  phantomjs_options: ['--load-images=no', '--disk-cache=false'] )
end

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
