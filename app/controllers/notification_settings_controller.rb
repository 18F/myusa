class NotificationSettingsController < ApplicationController

  before_filter :authenticate_user! #, only: [:index]

  layout 'dashboard'

  def index
    @authorizations = current_user.authorizations #oauth_tokens.select {|a| a.scopes.exists?('notifications')}
    pp @authorizations

    @applications = @authorizations.map(&:application)
  end

  def update
    if params[:id].present?
      resource = current_user.authorizations.find(params[:id])
    else
      resource = current_user
    end

    resource.notification_settings[params[:key]] = params_value
    resource.save!

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
