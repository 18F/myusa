module OauthHelper
  def oauth_deny_link(pre_auth, text)
    error = Doorkeeper::OAuth::ErrorResponse.new(
      state: pre_auth.state,
      name: :access_denied,
      redirect_uri: pre_auth.redirect_uri
    )
    if error.redirectable?
      link_to text, error.redirect_uri
    else
      link_to(text, oauth_pre_auth_delete_uri(pre_auth), method: :delete)
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

end
