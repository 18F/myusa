name 'all-in-one'
description 'MyUSA in a box!'
run_list ['role[all-in-one]']
default_attributes 'myusa' => {'user' => 'vagrant', 'group' => 'vagrant'}
