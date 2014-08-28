class FailureApp < Devise::FailureApp

  def scope_url
    opts = { client_id: warden_options[:client_id] }
    new_user_session_url(opts)
  end

end
