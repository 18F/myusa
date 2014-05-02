#!/usr/bin/python

import sys
import os
from subprocess import call

editor = os.environ.get('EDITOR', 'nano')
message_file = sys.argv[1]
# Used to figure out when we've reached the part in the commit message
# where the errors go.
error_header = '# GIT COMMIT MESSAGE FORMAT ERRORS:'

def check_format_rules(lineno, line):
    """
    Given a line number and a line, compare them against a set of rules.  If it
    it fails a given rule, return an error message.  If it passes all rules
    then return false.
    """
    # Since enumerate starts at 0
    real_lineno = lineno + 1
    if lineno == 0:
        if len(line) > 50:
            return "E%d: First line should be less than 50 characters in " \
                    "length." % (real_lineno,)
    if lineno == 1:
        if line:
            return "E%d: Second line should be empty." % (real_lineno,)
    if not line.startswith('#'):
        if len(line) > 72:
            return "E%d: No line should be over 72 characters long." % (
                    real_lineno,)
    return False


while True:
    # Temporary storage for the commit message so we can recreate it
    # and then append errors if there are any.
    commit_msg = list()
    errors = list()
    with open(message_file) as commit_fd:
        for lineno, line in enumerate(commit_fd):
            stripped_line = line.strip()
            # Break out of the loop if we've hit the error header
            if stripped_line == error_header:
                break
            commit_msg.append(line)
            e = check_format_rules(lineno, stripped_line)
            if e:
                errors.append(e)
    if errors:
        with open(message_file, 'w') as commit_fd:
            for line in commit_msg:
                commit_fd.write(line)
            commit_fd.write('%s\n' % (error_header,))
            for error in errors:
                commit_fd.write('#    %s\n' % (error,))
                print error
        re_edit = raw_input('Invalid git commit message format.  Would you '
                'like to re-edit it?  (If you answer no, your commit will '
                'fail) [Y/n]')
        if re_edit in ('N', 'n', 'NO', 'no', 'No', 'nO'):
            sys.exit(1)
        call('%s %s' % (editor, message_file), shell=True)
        continue
    # No errors (otherwise it would have either continued or exited) so lets
    # break out of the while loop and exit cleanly
    break