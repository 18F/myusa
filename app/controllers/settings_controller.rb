class SettingsController < ApplicationController

  before_filter :authenticate_user! #, only: [:index]

  layout 'dashboard'

  def notifications
    @authorizations = current_user.oauth_tokens.select {|a| a.scopes.exists?('notifications')}
    @applications = @authorizations.map(&:application)
  end

  def update
    current_user.settings[params[:key]] = params_value
    current_user.save!

    #TODO: don't hardcode redirect path to notifications
    redirect_to settings_notifications_path
  end

  private

  def params_value
    case params[:value]
    when 'false'
      false
    when 'true'
      true
    else
      params[:value]
    end
  end
end
