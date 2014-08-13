source 'https://rubygems.org'

## global additions from rails

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

## app dependencies
gem 'bootstrap-sass', '~> 3.2.0'
gem 'autoprefixer-rails'
gem 'devise'
gem 'devise-async'
gem 'omniauth'
gem 'oauth2'
gem 'omniauth-openid' #, :git => 'https://github.com/GSA/omniauth-openid.git', :branch => 'pape'
gem 'omniauth-google-oauth2'
gem 'mysql2'
gem 'secure_headers'
gem 'validates_email_format_of', :git => 'https://github.com/alexdunae/validates_email_format_of.git'
gem "paperclip", "~> 4.1"
gem "permanent_records", "~> 2.3.0"
gem 'font-awesome-sass'
gem "attr_encrypted"
gem "factory_girl"
gem 'capistrano', '~> 2.15'
gem 'capistrano-unicorn', :require => false
gem 'unicorn', :require => false

gem 'doorkeeper'

# Papertrail prevents records from being deleted.
# gem 'papertrail'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'
end

group :development do
  gem 'guard-livereload'
  gem 'railroady'
  gem 'quiet_assets'
  gem 'ruby_parser'
  gem 'slim'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/Spring
  gem 'spring'
  gem 'thin'
  gem "letter_opener"
  gem 'rubocop', require: false

  ## deploy dependencies
  gem 'berkshelf', '~> 3.0'
  gem 'chef'
  gem 'knife-ec2'
  gem 'knife-solo', github: 'matschaffer/knife-solo', submodules: true
  gem 'knife-solo_data_bag'
  gem 'unf'
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
  gem 'pry-plus', git: 'https://github.com/nhemsley/pry-plus.git'
  gem 'spring-commands-rspec'
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
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-its'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'rspec_junit_formatter', require: false # used by Shippable
  gem 'timecop'
  gem 'capybara-email'
end

group :production do
  gem 'newrelic_rpm'
end
