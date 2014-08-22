include_recipe 'mysql::server'

include_recipe 'mysql::client'
include_recipe 'database::mysql'

mysql_database node[:myusa][:database][:name] do
  connection(
    :host => node[:myusa][:database][:host],
    :username => 'root',
    :password => node[:mysql][:server_root_password]
  )
  action :create
end
