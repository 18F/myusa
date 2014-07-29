name "app-server"
description "The app server role for boxit"
run_list ["myusa-app", "nginx", "nodejs"]
# run_list ["passenger::install", "passenger::daemon", "nodejs"]
#env_run_lists "production" => ["recipe[passenger::config_prod]"], "testing" => ["recipe[passenger::config_test]"]
