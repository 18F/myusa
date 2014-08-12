module OauthHelper
  def scope_check_box_tag(scope)
    check_box_tag('scope[]', scope, true,
      id: ('scope_' + scope.gsub(/\./, '_')),
      multiple: true
    )
  end

  def profile_text_field(scope)
    field = Profile.attribute_from_scope(scope)
    value = current_user.profile.send(field)
    text_field_tag("profile[#{field}]", current_user.profile.send(field),
      disabled: value.present?
    )
  end
end
