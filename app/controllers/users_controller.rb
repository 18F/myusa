class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    q = User
    if !params.blank?
      search_params.each do |key, val|
        q = q.where(key => val)
      end
      if q.count == 0
        render :json => q.all, :status => 404
        return
      end
    end
    render :json => q.all
  end
  
  def show
    id = params[:id]
    uid = params[:uid]
    user = nil
    if id.blank? || id.to_i <= 0
      render :json => nil, :status => 422
    elsif User.exists?(id) && user = User.find(id)
      render :json => user
    else
      render :json => {}, :status => 404
    end
  end

  def create
    Rails.logger.debug "Creating!"
    begin
      u = User.create(create_params)
    rescue ActiveRecord::RecordNotUnique => e
      u && u.errors.add(:base, 'Dupliate record')
    end
    
    if u && u.errors.blank?
      u.update_attribute :encrypted_password, params[:encrypted_password] if params[:encrypted_password]
      u.update_attribute :confirmation_token, params[:confirmation_token] if params[:confirmation_token]
      render :json => u
    else
      Rails.logger.debug "Errors: #{u && u.errors.inspect}"
      render :json => {}, :status => 422
    end
  end

  def update
    Rails.logger.debug "Updating!"
    id = params[:id]
    uid = params[:uid]
    u = nil
    if (id && User.exists?(id) && u = User.find(id)) || (uid && u = User.where(uid: uid).first)
      u_params = update_params

      u_params.delete(:email) if u_params[:email].blank?
      Rails.logger.debug "Updating with #{u_params.inspect}"
      begin
        u.update_attributes(u_params)
      rescue ActiveRecord::RecordNotUnique => e
        u && u.errors.add(:base, 'Dupliate record')
      end

      if u.errors.blank?
        render :json => u
      else
        Rails.logger.debug "Errors: #{u && u.errors.inspect}"
        render :json => {}, :status => 422
      end
    else
      render :json => {}, :status => 404
    end
  end

  def destroy
    id = params[:id]
    uid = params[:uid]
    u = nil
    if (id && u=User.find(id)) || (uid && u = User.where(uid: uid).first)
      render :json => u.destroy
    else
      render :json => nil, :status => 422
    end
  end

  protected

  def nillify_blanks(hash={})
    hash.each { |k,v| hash[k]=nil if v.blank? }
    hash
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
 