# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

unless Rails.env.production? || Rails.env.staging?
  require 'rspec/core/rake_task'

  desc 'Default: run specs.'
  task :default => :spec

  desc "Run all specs"
  RSpec::Core::RakeTask.new(:spec)
end

Rails.application.load_tasks
