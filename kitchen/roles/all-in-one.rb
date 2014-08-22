name 'all-in-one'
description 'MyUSA in a box!'
run_list ['role[bare_bones]', 'role[app]', 'role[database]']
