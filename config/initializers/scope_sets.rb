SCOPE_SETS = {
    email:        [
                    {label: 'email', group: ['profile.email']}
                  ],
    name:         [
                    {
                      label: 'title', group: ['profile.title']
                    },
                    {
                      label: 'First name', group: %w(profile.first_name)
                    },
                    {
                      label: 'Middle name', group: %w(profile.middle_name)
                    },
                    {
                      label: 'Last name', group: %w(profile.last_name)
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

SELECT_MENU_SCOPES = %w(profile.gender profile.marital_status profile.state profile.suffix profile.title profile.is_parent profile.is_student profile.is_veteran)