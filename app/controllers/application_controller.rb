class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected

  def clear_return_to
    key = stored_location_key_for(:user)
    session.delete(key)
  end

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
    if current_user.sign_in_count == 1 && session[:user_return_to] !~ /auth\/authorize/
      new_mobile_recovery_path
    else
      stored_location_for(resource_or_scope) || profile_path
    end
  end

  # Overriding Devise method to allow for redirect_url
  def after_sign_out_path_for(resource_or_scope)
    url = params[:continue]
    if !url.blank? &&
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
