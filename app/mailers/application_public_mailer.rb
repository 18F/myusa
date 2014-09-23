class ApplicationPublicMailer < ActionMailer::Base
  def notify_is_public(application)
    @to      = 'myusa@gsa.gov'
    @message = "#{application.name} has requested to become public."
	attachments.inline['logo.png'] = File.read('app/assets/images/myusa-logo.png')
    mail(
      to: @to,
      subject: "#{application.name} has requested to become public"
    )
  end
end
