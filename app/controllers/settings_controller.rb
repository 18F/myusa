class SettingsController < ApplicationController

  before_filter :authenticate_user!

  before_filter :require_two_factor!, if: :two_factor_configured?

  layout 'dashboard'

  def account_settings
    @profile = current_user.profile
    @private_apps = current_user.oauth_applications.private?
    @public_apps = current_user.oauth_applications.public?
  end

end
