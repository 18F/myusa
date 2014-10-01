class FailureApp < Devise::FailureApp
  def scope_url
    opts = { client_id: warden_options[:client_id], login_required: true }
    new_user_session_url(opts)
  end

  def redirect
    store_location!
    #  supress the timedout flash alert message from rendering
    if flash[:timedout] && flash[:alert]
      flash.keep(:timedout)
      flash.keep(:alert)
    end
    redirect_to redirect_url
  end
end
