name 'database'
description 'sets up MySQL with MyUSA configuration'
run_list ['role[bare_bones]', 'myusa::database']
