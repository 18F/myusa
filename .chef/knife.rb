berkshelf_path										'kitchen'
cookbook_path    									['~/.berkshelf/cookbooks', 'kitchen/site-cookbooks']
data_bag_path    									'kitchen/data_bags'
encrypted_data_bag_secret 				'.databag_secret'
environment_path 									'kitchen/environments'
node_path        									'kitchen/nodes'
role_path       									'kitchen/roles'
ssl_verify_mode 									:verify_peer

knife[:aws_access_key_id]	=				ENV['AWS_ACCESS_KEY']
knife[:aws_secret_access_key] =		ENV['AWS_SECRET_KEY']
# Optional if you're using Amazon's STS
#knife[:aws_session_token] = 			ENV['AWS_SESSION_TOKEN']