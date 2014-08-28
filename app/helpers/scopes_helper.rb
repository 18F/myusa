module ScopesHelper

  SCOPE_GROUPS = [
    {
      name: :email,
      scopes: %w(profile.email)
    },
    {
      name: :name,
      scopes: %w(profile.title profile.first_name profile.middle_name
                 profile.last_name profile.suffix)
    },
    {
      name: :address,
      scopes: %w(profile.address profile.address2 profile.city profile.state
                profile.zip)
    },
    {
      name: :phone,
      scopes: %w(profile.phone_number profile.mobile_number)
    },
    {
      name: :identifiers,
      scopes: %w(profile.gender profile.marital_status profile.is_parent
                 profile.is_student profile.is_veteran profile.is_retired)
    }
  ]

  def scopes_by_group(scopes)
    SCOPE_GROUPS.each do |scope_group|
      filtered_scopes =  scopes.select {|s| scope_group[:scopes].include?(s) }
      yield(scope_group[:name], filtered_scopes)
    end
  end

  def scope_field_label(scope)
    label :scope, scope.gsub(/\./, '_'), t("scopes.#{scope}.label")
  end

  def profile_options_for_select(scope, value)
    case scope
    when 'profile.title'
      title_options_for_select(value)
    when 'profile.suffix'
      suffix_options_for_select(value)
    when 'profile.state'
      us_state_options_for_select(value)
    when 'profile.gender'
      gender_options_for_select(value)
    when 'profile.marital_status'
      maritial_status_options_for_select(value)
    when 'profile.is_parent'
      yes_no_options_for_select(value)
    when 'profile.is_student'
      yes_no_options_for_select(value)
    when 'profile.is_veteran'
      yes_no_options_for_select(value)
    when 'profile.is_retired'
      yes_no_options_for_select(value)
    end
  end

  def scope_field_tag(scope, opts={})
    return unless scope.starts_with?('profile.')

    field = Profile.attribute_from_scope(scope)
    value = current_user.profile.send(field)

    if !value.nil? && value != '' 
      profile_display_value(field, current_user.profile.send(field))
    else
      if profile_options = profile_options_for_select(scope, value)
        opts.merge!(prompt: t(:not_specified))
        select_tag "profile[#{field}]", profile_options, opts
      else
        opts.merge!(placeholder: t("scopes.#{scope}.placeholder"))
        text_field_tag "profile[#{field}]", current_user.profile.send(field), opts
      end
    end
  end

end
