source 'https://rubygems.org'

gem 'rails', '~> 4.1.0'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'mysql2'
gem "paperclip", "~> 4.1.1"
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
  gem 'better_errors'
  gem 'pry-rails'
  # this fork of pry-plus is 2.1.x-compatible
  # gem 'pry-plus', git: 'https://github.com/avantcredit/pry-plus.git'
end

## deploy dependencies
group :deploy do
  gem 'berkshelf', '~> 3.0'
  gem 'chef'
  gem 'knife-ec2'
  gem 'knife-solo' #, github: 'matschaffer/knife-solo', submodules: true
  gem 'knife-solo_data_bag'
  gem 'unf'
  gem 'capistrano', '~> 2.15'
  gem 'capistrano-unicorn', require: false
end

group :development, :test do
  gem 'oauth2'
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
  gem 'codeclimate-test-reporter', require: false
  gem 'rspec_junit_formatter', require: false # used by Shippable
end

group :staging, :production do
  gem 'unicorn', :require => false
  gem 'dalli'
end

group :production do
  gem 'newrelic_rpm'
end
