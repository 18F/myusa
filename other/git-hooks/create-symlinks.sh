#!/bin/sh

ln -s -f other/git_hooks/pre-commit .git/hooks/pre-commit
ln -s -f other/git_hooks/check-git-commit.py .git/hooks/check-git-commit.py
ln -s -f other/git_hooks/commit-msg .git/hooks/commit-msg