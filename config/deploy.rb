default_run_options[:pty] = true

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
#require 'new_relic/recipes'
require 'capistrano-unicorn'

set :application, 'myusa'
set :user, 'myusa'
set :web_user, "nobody"
set :web_group, "web"

set :default_stage, 'vagrant'
set :stages, %w(vagrant development staging ec2 production)

set :repository, 'https://github.com/18F/myusa.git'
set :branch, ENV['BRANCH'] || 'devel'
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :copy_exclude, [ '.ruby-gemset' ]
set :ssh_options, { :forward_agent => true }
set :default_shell, '/bin/bash -l'
set :use_sudo, false
set :keep_releases, 6
set :scm, :git
set :port, 22

set :bundle_without, [ :development, :test, :deploy ]

load 'config/deploy/base'
before 'deploy:assets:precompile','deploy:symlink_configs'
after 'deploy:restart', 'unicorn:reload'
