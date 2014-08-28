# contact us mailer
class ContactMailer < ActionMailer::Base
  default from: 'contact@gsa.gov'

  def contact_email(message)
    @message = message
    mail(to: 'myusa@gsa.gov', subject: 'New Message From MyUSA')
  end
end
