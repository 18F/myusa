class FailureApp < Devise::FailureApp
  def scope_url
    opts = { client_id: warden_options[:client_id] }
    new_user_session_url(opts)
  end

  def redirect
    store_location!
    if flash[:timedout] && flash[:alert]
      flash.keep(:timedout)
      flash.keep(:alert)
    else
      flash[:alert] = i18n_message unless warden_options[:client_id]
    end
    redirect_to redirect_url
  end
end
