class ApplicationPublicMailer < ActionMailer::Base
  layout 'mailers/notification_template'
  def notify_is_public(application, user)
    @to      = 'myusa@gsa.gov'
    @message = "<p>#{application.name} has requested to become public.</p>"\
               '<p><u>App owner details</u>'\
               "<br><br>First name: #{user.profile.first_name}"\
               "<br>Last name: #{user.profile.last_name}"\
               "<br>Email: #{user.profile.email}</p>".html_safe
    attachments.inline['logo.png'] = File.read(
      'app/assets/images/myusa-logo.png'
    )
    mail(
      to: @to,
      subject: "#{application.name} has requested to become public"
    )
  end
end
