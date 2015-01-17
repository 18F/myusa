class SettingsController < ApplicationController

  before_filter :authenticate_user!

  before_filter :require_two_factor!, if: :two_factor_configured?

  layout 'dashboard'

  def account_settings; end

end
