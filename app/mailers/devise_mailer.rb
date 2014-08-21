class DeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def authentication_instructions(resource, token)
    @token = token
    devise_mail(resource, :authentication_instructions)
  end

end
