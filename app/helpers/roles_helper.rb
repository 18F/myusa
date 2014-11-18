module RolesHelper

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

  # helper_method(:require_owner_or_admin!, :require_owner!, :require_admin!, :require_two_factor!)
end
