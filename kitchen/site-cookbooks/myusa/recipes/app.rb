include_recipe "nodejs"

app_id = 'myusa'

deploy_to_dir = "/var/www/#{app_id}"


# set up user and group
group node[:myusa][:user][:group]
include_recipe 'user'
user_account node[:myusa][:user][:username] do #'myusa' do #node[:myusa][:user][:username] do
  gid node[:myusa][:user][:group]
  # puts node[:myusa][:user][:username]
  ssh_keys node[:myusa][:user][:deploy_keys]
  action :create
end

# set up directory structure ...
directory deploy_to_dir do
  recursive true
  owner node[:myusa][:user][:username]
  group node[:myusa][:user][:group]
end

%w[ shared releases ].each do |subdir|
  directory "#{deploy_to_dir}/#{subdir}" do
    owner node[:myusa][:user][:username]
    group node[:myusa][:user][:group]
  end
end

%w[ config config/initializers log ].each do |subdir|
  directory "#{deploy_to_dir}/shared/#{subdir}" do
    owner node[:myusa][:user][:username]
    group node[:myusa][:user][:group]
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
