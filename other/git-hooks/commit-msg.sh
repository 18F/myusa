#!/bin/sh

# Needed to get a tty for the python script
exec < /dev/tty

.git/hooks/check-git-commit.py $1