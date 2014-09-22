class ApplicationPublicMailer < ActionMailer::Base
  def notify_is_public(application)
    @to      = 'myusa@gsa.gov'
    @message = "#{application.name} has gone public."
    mail(
      to: @to,
      subject: "#{application.name} has gone public"
    )
  end
end
