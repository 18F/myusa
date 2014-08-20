module OauthHelper
  def scope_groups(scopes_list)
    # Check for address and address2
    pre_auth_scopes = scopes_list.to_a

    scopes = insert_extra_scope pre_auth_scopes,
                                'profile.address',
                                'profile.address2'

    ordered_scopes = SCOPE_SETS.map { |k| k[1].map { |g| g[:group] } }.flatten

    # Sort array of scopes according to requirements
    pre_auth_scopes = scopes.sort_by do |x|
      ordered_scopes.map { |k| k }.flatten.index x
    end

    @pre_auth_groups = create_groups pre_auth_scopes
  end

  def scope_check_box_tag(scope)
    check_box_tag('scope[]', scope, true,
      id: ('scope_' + scope.gsub(/\./, '_')),
      multiple: true
    )
  end

  def profile_text_field(scope, options={})
    field = Profile.attribute_from_scope(scope)
    value = current_user.profile.send(field)
    if value.present?
      return current_user.profile.send(field)
    else
      options.merge!(placeholder: t("scopes.#{scope}.placeholder"), disabled: value.present?)
      text_field_tag "profile[#{field}]", current_user.profile.send(field), options
    end
  end

  def oauth_deny_link(pre_auth, text, options={})
    error = Doorkeeper::OAuth::ErrorResponse.new(
      state: pre_auth.state,
      name: :access_denied,
      redirect_uri: pre_auth.redirect_uri
    )
    if error.redirectable?
      link_to text, error.redirect_uri, options
    else
      link_to text, oauth_pre_auth_delete_uri(pre_auth), options.merge(method: :delete)
    end
  end

  def oauth_pre_auth_delete_uri(pre_auth)
    oauth_authorization_path(
      client_id: pre_auth.client.uid,
      redirect_uri: pre_auth.redirect_uri,
      state: pre_auth.state,
      response_type: pre_auth.response_type,
      scope: pre_auth.scope
    )
  end

  private

  def insert_extra_scope(arry, first, second)
    arry.push second if arry.include?(first) && !arry.include?(second)
    arry
  end

  def create_groups(pre_auth_scopes)
    pre_auth_groups = []
    sets            = {}
    SCOPE_SETS.keys.each do |set_name|
      sets[set_name] = []
      SCOPE_SETS[set_name].each do |set|
        inter = pre_auth_scopes & set[:group]
        next if inter.empty?
        sets[set_name] << {label: set[:label], group: inter}
      end
      next if sets[set_name].empty?
      pre_auth_groups.push(
        name:   set_name,
        groups: sets[set_name]
      )
    end
    pre_auth_groups
  end
end
