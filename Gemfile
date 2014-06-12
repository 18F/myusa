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
gem 'bootstrap-sass'
gem 'devise'
gem 'devise-async'
gem 'omniauth'
gem 'songkick-oauth2-provider', :git => 'https://github.com/adam-at-mobomo/oauth2-provider.git', :branch => 'rails-4-compatibility-with-bearer-and-client-credential-support', :require => 'songkick/oauth2/provider'
gem 'oauth2'
gem 'omniauth-openid' #, :git => 'https://github.com/GSA/omniauth-openid.git', :branch => 'pape'
gem 'mysql2'
gem 'secure_headers'
gem 'validates_email_format_of', :git => 'https://github.com/alexdunae/validates_email_format_of.git'
gem "paperclip", "~> 4.1"
gem "permanent_records", "~> 2.3.0"

# Papertrail prevents records from being deleted.
# gem 'papertrail'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'
end

group :development do
  # Use Capistrano for deployment
  gem 'capistrano',  '~> 3.1'
  gem 'capistrano-rails', '~> 1.1'
#  gem 'capistrano-maintenance', github: "capistrano/capistrano-maintenance"
  gem 'rvm1-capistrano3', require: false
  gem 'guard-livereload'
  gem 'railroady'
  gem 'quiet_assets'
  gem 'ruby_parser'
  gem 'slim'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/Spring
  gem 'spring'
  gem 'thin'
  gem "letter_opener"
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
  gem 'pry-plus'
  gem 'rb-fsevent' if `uname` =~ /Darwin/
  gem 'spring-commands-rspec'
  gem 'rspec_api_blueprint', require: false
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'fakeweb'
  gem 'launchy'
  gem 'rspec-rails'
  gem 'simplecov', require: false
end

group :production do
  gem 'newrelic_rpm'
end
