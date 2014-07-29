name "mysql"
description "Base role for DB support"
run_list ["mysql::client", "mysql::server"]
default_attributes  mysql: {
				              server_root_password: ''
                    }