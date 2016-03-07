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

  # Considering this is followed by a test that the URL matches registered domain,
  # I decided to make this simpler since prior version was rejecting valid URLs
  def valid_url?(uri)
    parsed = URI.parse(uri)
    return (parsed.scheme == 'http' || parsed.scheme == 'https')
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
    if current_user.sign_in_count == 1 && session[:user_return_to] !~ /oauth\/authorize/
      session[:two_factor_return_to] = mobile_recovery_welcome_path
      new_mobile_recovery_path
    else
      require_two_factor! if current_user.two_factor_required
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

  def authenticate_user!(opts={})
    super
    require_two_factor! if current_user.two_factor_required
    current_user
  end

  def require_owner_or_admin!
    require_owner!
  rescue SimpleRole::AccessDenied => e
    require_admin!
  end

  def require_owner!
    authenticate_user!
    current_user.has_role?(:owner, resource) or raise SimpleRole::AccessDenied
  end

  def require_admin!
    authenticate_user!
    if current_user.has_role?(:admin)
      require_two_factor!
      UserAction.admin_action.create(data: params)
      return true
    else
      raise SimpleRole::AccessDenied
    end
  end

  def require_two_factor!
    warden.authenticate!(scope: :two_factor)
  end

  def two_factor_configured?
    current_user.mobile_number.present?
  end
end
