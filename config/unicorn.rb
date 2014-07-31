# Set the working application directory
working_directory "/var/www/myusa/current"

# Unicorn PID file location
pid "/var/www/myusa/shared/unicorn.pid"

# Path to logs
stderr_path "/var/www/myusa/shared/log/unicorn.log"
stdout_path "/var/www/myusa/shared/log/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.myusa.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30
