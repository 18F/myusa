class SessionsController < Devise::SessionsController

  def new
    super
  end

  def create
    user = User.find_by_email(params[:user][:email])
    if !user
      user = User.create!(email: params[:user][:email])
    end

    raw = user.set_authentication_token

    render :text => 'CYM'
  end

end
