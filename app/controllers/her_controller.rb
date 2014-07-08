class HerController < ApplicationController
  skip_before_action :verify_authenticity_token

  @base_type = Object

  def index
    q = base_class
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
    obj = nil
    if id.blank? || id.to_i <= 0
      render :json => nil, :status => 422
    elsif obj = find_by_id
      render :json => obj
    else
      render :json => {}, :status => 404
    end
  end

  def create
    Rails.logger.debug "Creating #{base_class.name}!"
    begin
      o = base_class.create(create_params)
    rescue ActiveRecord::RecordNotUnique => e
      o && o.errors.add(:base, 'Dupliate record')
    end

    if o && o.errors.blank?
      o.update_attribute :encrypted_password, params[:encrypted_password] if params[:encrypted_password]
      o.update_attribute :confirmation_token, params[:confirmation_token] if params[:confirmation_token]
      render :json => o
    else
      Rails.logger.debug "Errors: #{o && o.errors.inspect}"
      render :json => {}, :status => 422
    end
  end

  def update
    Rails.logger.debug "Updating #{self}!"
    o = nil
    if o = find_by_id
      u_params = update_params

      u_params.delete(:email) if u_params[:email].blank?
      Rails.logger.debug "Updating with #{u_params.inspect}"
      begin
        o.update_attributes(u_params)
      rescue ActiveRecord::RecordNotUnique => e
        o && o.errors.add(:base, 'Dupliate record')
      end

      if o.errors.blank?
        render :json => o
      else
        Rails.logger.debug "Errors: #{o && o.errors.inspect}"
        render :json => {}, :status => 422
      end
    else
      render :json => {}, :status => 404
    end
  end

  def destroy
    o = nil
    if o = find_by_id
      render :json => o.destroy
    else
      render :json => nil, :status => 422
    end
  end

  protected

  def find_by_id
    id = params[:id]
    o = nil
    id && base_class.exists?(id) && o = base_class.find(id)
    o
  end

  def base_class(klass=nil)
    self.class.base_class
  end

  def self.base_class(klass=nil)
    if klass
      @base_type = klass
    else
      @base_type
    end
  end

  def nillify_blanks(hash={})
    hash.each { |k,v| hash[k]=nil if v.blank? }
    hash
  end

  def search_params
    params.permit!
  end

  def create_params
    params.permit!
  end

  def update_params
    params.permit!
  end
end
