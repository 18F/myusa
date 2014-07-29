

app_id = 'myusa-server'

#TODO: this is crap ...
user = node[:myusa][:user]
group = node[:myusa][:group]

# set up directories ...
deploy_to_dir = "/var/www/#{app_id}"
shared_dir = "#{deploy_to_dir}/shared"
config_dir = "#{shared_dir}/config"
initializers_dir = "#{config_dir}/initializers"
log_dir = "#{shared_dir}/log"
pids_dir = "#{shared_dir}/pids"
releases_dir = "#{deploy_to_dir}/releases"

working_dir = "#{deploy_to_dir}/current"

directory deploy_to_dir do
  recursive true
  owner user
  group group
end

[shared_dir, config_dir, initializers_dir, log_dir, pids_dir, releases_dir].each do |dir|
  directory dir do
    owner user
    group group
  end
end

package "libssl-dev"
package "zlib1g-dev"

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
rbenv_ruby node[:myusa][:ruby_version]

rbenv_gem "bundler" do
  ruby_version node[:myusa][:ruby_version]
end

#set up templates for application secrets
template "#{config_dir}/secrets.yml" do
  source "secrets.yml.erb"
end

template "#{initializers_dir}/devise.rb" do
  source "devise.rb.erb"
  variables(
    :devise_secret_key => node[:myusa][:devise][:secret_key]
  )
end

# set up the database
database_name = "#{app_id}_#{node[:myusa][:rails_env]}"

template "#{config_dir}/database.yml" do
  source "database.yml.erb"
  variables(
    :rails_env => node[:myusa][:rails_env],
    :name => node[:myusa][:dbname],
    :host => node[:myusa][:database][:host],
    :username => node[:myusa][:database][:username],
    :password => node[:myusa][:database][:password]
  )
end

# set up unicorn and nginx
template "#{config_dir}/unicorn.rb" do
  source "unicorn.rb.erb"
  variables(
    :working_dir => working_dir,
    :pids_dir => pids_dir,
    :log_dir => log_dir,
    :app_id => app_id
  )
end

include_recipe "nginx"

template "/etc/nginx/conf.d/#{app_id}.conf" do
  source "nginx.conf.erb"
  variables(
    :working_dir => working_dir,
    :app_id => app_id
  )
end
#
# nginx_conf_file "mywebsite.com" do
#   socket "/var/www/myapp/shared/tmp/sockets/unicorn.socket"
# end

# notify nginx ...
