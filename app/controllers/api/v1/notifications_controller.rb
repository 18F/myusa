class Api::V1::NotificationsController < Api::ApiController
  before_filter :oauthorize_scope
  
  #POST /api/notifications
  #
  #This will create a notification for the authenticated user.  The user will be able to view the notification through a user interface, and optionally by email.
  #
  # + Parameters
  #
  #  + subject (required, string, `Test notification`)
  #  + body (optional, string, `This is a test`)
  
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
