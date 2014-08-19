source 'https://rubygems.org'

gem 'rails', '~> 4.1.0'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
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
gem 'doorkeeper'

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
end

group :deploy do
  ## deploy dependencies
  gem 'berkshelf', '~> 3.0'
  gem 'chef'
  gem 'knife-ec2'
  gem 'knife-solo', github: 'matschaffer/knife-solo', submodules: true
  gem 'knife-solo_data_bag'
  gem 'unf'
  gem 'capistrano', '~> 2.15'
  gem 'capistrano-unicorn', :require => false
end

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman', require: false
  gem 'crack'
  gem 'guard'
  gem 'guard-brakeman'
  gem 'guard-migrate'
  gem 'guard-rspec'
  gem 'pry-rails'
  # this fork of pry-plus is 2.1.x-compatible
  gem 'pry-plus', git: 'https://github.com/avantcredit/pry-plus.git'
#  gem 'rspec_api_blueprint', require: false
  gem 'better_errors'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'site_prism'
  gem 'fakeweb'
  gem 'launchy'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-csv', require: false
  gem 'rspec_junit_formatter', require: false # used by Shippable
  gem 'timecop'
  gem 'capybara-email'
  gem 'oauth2'
end

group :staging, :production do
  gem 'unicorn', :require => false
end

group :production do
  gem 'newrelic_rpm'
end
