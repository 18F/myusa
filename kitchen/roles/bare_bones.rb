name "bare-bones"
description "The base role for all systems"
run_list ["apt", "build-essential", "fail2ban", "git", "hostname", "openssl", "ntp", 'ssl_certificate', "sudo"]
