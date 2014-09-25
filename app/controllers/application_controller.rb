
# ApplicationController
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  private

  def valid_url?(uri)
    !!((uri =~ URI.regexp(%w(http https))) &&
      URI.parse(uri).host =~
        /^(localhost|(([0-9]{1,3}\.){3}[0-9]{1,3})|([a-z0-9]+\.)+[a-z]{2,5})$/i)
  rescue URI::InvalidURIError
    false
  end

  def member_subdomain?(url_list, url)
    url_list.any? do |list_url|
      list_host = URI.parse(list_url).host
      url_host = URI.parse(url).host
      list_host == url_host || url_host.ends_with?(".#{list_host}")
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || profile_path
  end

  # Overriding Devise method to allow for redirect_url
  def after_sign_out_path_for(resource_or_scope)
    url = params[:continue]
    oauth_params = params.slice(
      'client_id', 'redirect_uri', 'state', 'response_type', 'scope'
    )
    if url == oauth_authorization_path && oauth_params.present?
      return oauth_authorization_path(oauth_params)
    elsif !url.blank? &&
       valid_url?(url) &&
       @logged_out_user &&
       member_subdomain?(
         Doorkeeper::Application.authorized_for(@logged_out_user).map(&:url).compact,
         url)
      return url
    end
    super(resource_or_scope)
  end
end
