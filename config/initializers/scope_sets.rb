SCOPE_SETS = {
    email:        [
                    {label: 'email', group: ['profile.email']}
                  ],
    name:         [
                    {
                      label: 'title', group: ['profile.title']
                    },
                    {
                      label: 'name', group: %w(profile.first_name profile.middle_name profile.last_name)
                    },
                    {
                      label: 'suffix', group: ['profile.suffix']
                    },
                  ],
    address:      [
                    {
                      label: 'address', group: ['profile.address']
                    },
                    {
                      label: 'address2', group: ['profile.address2']
                    },
                    {
                      label: 'address3', group: %w(profile.city profile.state profile.zip)
                    }
                  ],
    phone:        [
                    {
                     label: 'phone', group: %w(profile.phone_number profile.mobile_number)
                    }
                  ],
    identifiers:  [
                    {
                      label: 'gender', group: ['profile.gender']

                    },
                    {
                      label: 'marital_status', group: ['profile.marital_status']
                    },
                    {
                      label: 'is_parent', group: ['profile.is_parent']

                    },
                    {
                      label: 'is_student', group: ['profile.is_student']
                    },
                    {
                      label: 'is_veteran', group: ['profile.is_veteran']
                    }
                  ]
}