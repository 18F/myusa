# Set the working application directory
working_directory "/var/www/myusa-server/current"

# Unicorn PID file location
pid "/var/www/myusa-server/shared/unicorn.pid"

# Path to logs
stderr_path "/var/www/myusa-server/shared/log/unicorn.log"
stdout_path "/var/www/myusa-server/shared/log/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.myusa-server.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30
