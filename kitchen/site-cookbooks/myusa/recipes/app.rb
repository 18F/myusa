include_recipe "nodejs"

app_id = 'myusa-server'

deploy_to_dir = "/var/www/#{app_id}"

# set up directory structure ...
directory deploy_to_dir do
  recursive true
  owner node[:myusa][:user]
  group node[:myusa][:group]
end

%w[ shared releases ].each do |subdir|
  directory "#{deploy_to_dir}/#{subdir}" do
    owner node[:myusa][:user]
    group node[:myusa][:group]
  end
end

%w[ config config/initializers log ].each do |subdir|
  directory "#{deploy_to_dir}/shared/#{subdir}" do
    owner node[:myusa][:user]
    group node[:myusa][:group]
  end
end

working_dir = "#{deploy_to_dir}/current"

# set up rubies ...
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby node[:myusa][:ruby_version]

rbenv_gem "bundler" do
  ruby_version node[:myusa][:ruby_version]
end

#set up templates for application secrets
template  "#{deploy_to_dir}/shared/config/secrets.yml" do
  source "secrets.yml.erb"
end

# TODO: this file should reference secrets.yml
template  "#{deploy_to_dir}/shared/config/initializers/devise.rb" do
  source "devise.rb.erb"
  variables(
    :devise_secret_key => node[:myusa][:secrets][:devise_secret_key]
  )
end

# set up the database
include_recipe "mysql::client"

template  "#{deploy_to_dir}/shared/config/database.yml" do
  source "database.yml.erb"
  variables(
    :rails_env => node[:myusa][:rails_env],
    :database => node[:myusa][:database][:name],
    :host => node[:myusa][:database][:host],
    :username => node[:myusa][:database][:username],
    :password => node[:myusa][:database][:password]
  )
end

# # set up unicorn and nginx

template "#{deploy_to_dir}/shared/config/unicorn.rb" do
  source "unicorn.rb.erb"
  variables(
    :working_dir => "#{deploy_to_dir}/current",
    :pids_dir => "#{deploy_to_dir}/shared",
    :log_dir => "#{deploy_to_dir}/shared/log",
    :app_id => app_id
  )
end

include_recipe "nginx"

template "/etc/nginx/conf.d/#{app_id}.conf" do
  source "nginx.conf.erb"
  variables(
    :working_dir => "#{deploy_to_dir}/current",
    :app_id => app_id
  )
end
#
# nginx_conf_file "mywebsite.com" do
#   socket "/var/www/myapp/shared/tmp/sockets/unicorn.socket"
# end

# notify nginx ...
