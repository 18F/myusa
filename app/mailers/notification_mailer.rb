class NotificationMailer < MyusaMailer
  layout 'mailers/notification_template'
  def notification_email(notification)
    @notification = notification
    @app = @notification.app
    @user = User.find @notification.user_id
    @metadata = {
      title: t('email.notification.subject', name: @app.name, subject: @notification.subject),
      subject: @notification.subject,
      footer: true
    }

    mail(
      to: @user.email,
      subject: @metadata[:subject]
    )
  end
end
