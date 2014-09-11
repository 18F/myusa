include_recipe "nodejs"

app_id = 'myusa'

deploy_to_dir = "/var/www/#{app_id}"

secrets = Chef::EncryptedDataBagItem.load(node[:myusa][:rails_env], "myusa")

# set up user and group
group node[:myusa][:user][:group]
include_recipe 'user'
user_account node[:myusa][:user][:username] do #'myusa' do #node[:myusa][:user][:username] do
  gid node[:myusa][:user][:group]
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

%w[ config config/initializers log system ].each do |subdir|
  directory "#{deploy_to_dir}/shared/#{subdir}" do
    owner node[:myusa][:user][:username]
    group node[:myusa][:user][:group]
  end
end

# set up rubies ...
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby node[:myusa][:ruby_version]

rbenv_gem "bundler" do
  ruby_version node[:myusa][:ruby_version]
end

# set up templates for application secrets
template  "#{deploy_to_dir}/shared/config/secrets.yml" do
  source "secrets.yml.erb"
  variables(
    rails_env: node[:myusa][:rails_env],
    secret_key_base: secrets['secret_key_base'],
    devise_secret_key: secrets['devise_secret_key'],
    aws_ses_username: secrets['aws_ses_username'],
    aws_ses_password: secrets['aws_ses_password'],
    omniauth_google_app_id: secrets['omniauth_google_app_id'],
    omniauth_google_secret: secrets['omniauth_google_secret']
  )
end

# Memcache configuration
template "#{deploy_to_dir}/shared/config/memcached.yml" do
  source 'memcached.yml.erb'
  variables(
    memcached_host: node[:myusa][:memcached][:host]
  )
end

# New Relic configuration
template "#{deploy_to_dir}/shared/config/newrelic.yml" do
  source 'newrelic.yml.erb'
  variables(
    newrelic_license_key: secrets['newrelic_license_key']
  )
end

# set up the database
include_recipe "mysql::client"

template "#{deploy_to_dir}/shared/config/database.yml" do
  source "database.yml.erb"
  variables(
    rails_env: node[:myusa][:rails_env],
    database: node[:myusa][:database][:name],
    host: node[:myusa][:database][:host],
    port: node[:myusa][:database][:port],
    username: node[:myusa][:database][:username],
    password: secrets['mysql_password'],
    encryption_key: secrets['mysql_encryption_key']
  )
end

service 'nginx' do
  supports status: true, restart: true, reload: true
  action   :restart
end

directory "/etc/nginx/conf.d", {}

template "/etc/nginx/conf.d/#{app_id}.conf" do
  source "nginx.conf.erb"
  notifies :restart, "service[nginx]"
  variables(
    working_dir: "#{deploy_to_dir}/current",
    app_id: app_id
  )
end
#
# nginx_conf_file "mywebsite.com" do
#   socket "/var/www/myapp/shared/tmp/sockets/unicorn.socket"
# end

# notify nginx ...
