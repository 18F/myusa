include_recipe 'mysql::server'

include_recipe 'mysql::client'
include_recipe 'database::mysql'

mysql_connection_info = {
  host: 'localhost',
  username: 'root',
  password: ''
}

mysql_database node[:myusa][:database][:name] do
  connection mysql_connection_info
  action :create
end

mysql_database_user node[:myusa][:database][:username] do
  connection mysql_connection_info
  password node[:myusa][:database][:password]
  database_name node[:myusa][:database][:name]
  privileges [:all] # TOOO: FIXME
  host '%' # TODO: FIXME
  action :grant
end
