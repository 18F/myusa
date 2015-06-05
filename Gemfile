source 'https://rubygems.org'
ruby '2.2.2' # CF Rails buildpack demands explicit ruby version

gem 'rails', '4.1.9' # update to 4.1.12 when released, due to
                     # https://github.com/rails/rails/pull/19479
                     # In our case, specs fail because of simple_role::has_role?
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'mysql2'
## app dependencies
gem 'bootstrap-sass', '~> 3.2.0'
gem 'autoprefixer-rails'
gem 'devise'
gem 'omniauth'
gem 'omniauth-openid' #, :git => 'https://github.com/GSA/omniauth-openid.git', :branch => 'pape'
gem 'omniauth-google-oauth2'
gem 'secure_headers'
gem 'permanent_records', '~> 2.3.0'
gem 'font-awesome-sass'
gem 'attr_encrypted'
gem 'doorkeeper', '~> 1.4'
gem 'rails-observers'
gem 'twilio-ruby'
gem 'bootstrap_tokenfield_rails'
gem 'will_paginate'

# TODO: Check this again soon for a new release (after 9/1/14) -- Yoz
gem 'validates_email_format_of'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc'
end

group :development do
  gem 'guard-livereload'
  gem 'quiet_assets'
  gem 'ruby_parser'
  gem 'thin'
  gem 'letter_opener'
  gem 'rubocop', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'oauth2'
  gem 'pry-rails'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'site_prism'
  gem 'fakeweb'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'capybara-email'
  gem 'sms-spec'
  gem 'codeclimate-test-reporter', require: false
  gem 'rspec_junit_formatter', require: false # used by Shippable
end

group :staging, :production do
  gem 'unicorn', :require => false
  gem 'dalli-elasticache'
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end

group :production do
  gem 'logstasher'
end
