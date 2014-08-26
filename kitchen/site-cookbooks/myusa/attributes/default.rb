
default[:myusa][:rails_env] = 'staging'
default[:myusa][:ruby_version] = '2.1.2'

default[:myusa][:user][:username] = 'myusa'
default[:myusa][:user][:group] = 'myusa'

default[:myusa][:secrets][:devise_secret_key] = '322a03b72aac1e453a21cec4120d585d0e897fd9d1f41454ae422bb94afe275da162a68ea8ce7a3441dc40a5c091d012651a52b7e5fa7741a0e402d87c483569'
default[:myusa][:secrets][:aws_ses_username] = ''
default[:myusa][:secrets][:aws_ses_password] = ''

default[:myusa][:database][:name] = 'myusa_staging' #default[:myusa][:rails_env]
default[:myusa][:database][:host] = 'localhost'
default[:myusa][:database][:port] = '3306'
default[:myusa][:database][:username] = 'myusa'
default[:myusa][:database][:password] = 'secret!'
