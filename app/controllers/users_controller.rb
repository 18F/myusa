class UsersController < HerController
  base_class User

  protected

  def find_by_id
    id = params[:id]
    uid = params[:uid]
    o = nil
    (id && User.exists?(id) && o = User.find(id)) || (uid && o = User.where(uid: uid).first)
    o
  end

  def search_params
    nillify_blanks(params.permit(:email, :confirmation_token,
     :unconfirmed_email, :remember_token))
  end

  def create_params
    nillify_blanks(params.permit(:uid, :email, :encrypted_password,
     :confirmation_sent_at, :confirmation_token))
  end

  def update_params
    nillify_blanks(params.permit(:email, :password, :password_confirmation,
     :confirmed_at, :created_at, :unconfirmed_email, :updated_at,
     :encrypted_password, :confirmation_sent_at,
     :confirmation_token, :current_sign_in_at, :current_sign_in_ip,
     :failed_attempts, :last_sign_in_at, :last_sign_in_ip, :locked_at,
     :remember_created_at, :remember_token, :reset_password_sent_at,
     :reset_password_token, :sign_in_count, :uid, :unlock_token))
  end
end
 