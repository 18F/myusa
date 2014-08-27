# Set up mysql with root password

secrets = Chef::EncryptedDataBagItem.load("secrets", "myusa")
node.set['mysql']['server_root_password'] = secrets['mysql_root_password']
include_recipe 'mysql::server'

# Set up databases and users

include_recipe 'mysql::client'
include_recipe 'database::mysql'

mysql_connection_info = {
  host: 'localhost',
  username: 'root',
  password: node['mysql']['server_root_password']
}

mysql_database node[:myusa][:database][:name] do
  connection mysql_connection_info
  action :create
end

mysql_database_user node[:myusa][:database][:username] do
  connection mysql_connection_info
  password secrets['mysql_password']
  database_name node[:myusa][:database][:name]
  privileges [:all] # TOOO: FIXME
  host '%' # TODO: FIXME
  action :grant
end
