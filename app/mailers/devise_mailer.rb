class DeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def authentication_instructions(record, token, opts={})
    @token = token
    devise_mail(record, :authentication_instructions, opts)
  end

end
