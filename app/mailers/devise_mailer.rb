class DeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def authentication_instructions(record, token, opts = {})
    @token = token
    @remember_me = true if opts[:remember_me]
    devise_mail(record, :authentication_instructions, opts)
  end

end
