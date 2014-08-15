SCOPE_GROUPS = {
    email:        ['profile.email'],
    name:         %w(profile.title profile.first_name profile.middle_name profile.last_name suffix),
    address:      %w(profile.address profile.address2 profile.city profile.state profile.zip),
    phone:        %w(profile.phone_number profile.mobile_number),
    identifiers:  %w(profile.gender profile.marital_status profile.is_parent profile.is_student profile.is_veteran profile.is_retired)
}