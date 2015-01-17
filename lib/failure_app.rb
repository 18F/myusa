class FailureApp < Devise::FailureApp
  def scope_url
    case scope
    when :user
      opts = { client_id: warden_options[:client_id], login_required: true }
      new_user_session_url(opts)
    when :two_factor
      user = warden.user(:user)
      if user.mobile_number.present?
        user.create_sms_code!(mobile_number: user.mobile_number)
        users_factors_sms_url
      else
        new_mobile_recovery_path
      end
    end
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
