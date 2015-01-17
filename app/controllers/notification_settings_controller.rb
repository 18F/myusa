class NotificationSettingsController < ApplicationController

  before_filter :authenticate_user!

  layout 'dashboard'

  def index
    @authorizations = current_user.authorizations.select {|a| a.scopes.exists?('notifications')}
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
    if params[:type] == 'boolean'
      ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:value])
    else
      params[:value]
    end
  end
end
