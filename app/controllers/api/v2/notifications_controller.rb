class Api::V2::NotificationsController < Api::ApiController
  before_filter :oauthorize_scope
  
  def create
    notification = @user.notifications.build(notification_params)
    notification.received_at = Time.now
    notification.user_id = @user.id
    notification.app_id = @app.id
    if notification.save
      render :json => notification, :status => 200
    else
      render :json => {:message => notification.errors}, :status => 400
    end
  end
  
  protected
  
  def notification_params
    params.require(:notification).permit(:body, :subject)
  end
  
  def no_scope_message
    "You do not have permission to send notifications to that user."
  end
  
  def oauthorize_scope
    validate_oauth(OauthScope.where(scope_name: 'notifications'))
  end
  
end
