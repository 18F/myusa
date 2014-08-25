name 'app'
description 'Runs the MyUSA Rails application'
run_list ['role[bare_bones]', 'myusa::app']
