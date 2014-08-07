require 'email_authenticatable'

class User < ActiveRecord::Base
  has_many :authentications, :dependent => :destroy
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  has_one :profile, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  validates_acceptance_of :terms_of_service
  validates_presence_of :uid
  validates_uniqueness_of :uid
  validates_email_format_of :email, {:allow_blank => false}
  validates_format_of :zip, :with => /\A\d{5}?\z/, :allow_blank => true, :message => "should be in the form 12345"

  before_validation :generate_uid
  after_create :create_profile

  devise :omniauthable, :email_authenticatable, :rememberable

  attr_accessor :just_created, :auto_approve

  PROFILE_ATTRIBUTES = [:title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :phone, :mobile, :gender, :marital_status, :is_parent, :is_retired, :is_student, :is_veteran]
  SCOPE_ATTRIBUTES = PROFILE_ATTRIBUTES + [:email]

  def sandbox_apps
    self.apps.sandbox
  end

  def authorized_apps
    self.oauth2_authorizations.all.collect{ |a| a.client.try(:owner) }.compact
  end

  class << self
    # def find_for_open_id(access_token, signed_in_resource = nil, user_params = nil)
    #   data = access_token.info
    #   authentications_scope = (signed_in_resource && signed_in_resource.authentications) || Authentication
    #   authentication = authentications_scope.find_by_uid_and_provider(access_token.uid, access_token.provider)
    #   if authentication
    #     authentication.user
    #   elsif signed_in_resource
    #     signed_in_resource.authentications.new(:uid => access_token.uid, :provider => access_token.provider, :data => access_token)
    #     signed_in_resource.save
    #     signed_in_resource
    #   else
    #     user = User.new(:email => data['email'])
    #     user.terms_of_service = (user_params && user_params[:terms_of_service]) || false
    #     [:email, :terms_of_service].each {|param| user_params.delete param} if user_params
    #     user.profile = Profile.new(user_params || {:first_name => data["first_name"], :last_name => data["last_name"]})
    #     user.skip_confirmation!
    #     user.authentications.new(:uid => access_token.uid, :provider => access_token.provider, :data => access_token)
    #     user.save
    #     user
    #   end
    # end

    def find_or_create_from_omniauth(auth)
      if (authentication = Authentication.find_by_uid(auth.uid))
        authentication.user
      elsif (user = User.find_by_email(auth.info.email))
        user.authentications.build(provider: auth.provider, uid: auth.uid)
        user.save!
        user
      else
        User.create do |user|
          user.email = auth.info.email
          user.authentications.build(provider: auth.provider, uid: auth.uid)
        end
      end
    end

  end

  def first_name
    self.profile ? self.profile.first_name : @first_name
  end

  def first_name=(first_name)
    @first_name = first_name
  end

  def zip
    self.profile ? self.profile.zip : @zip
  end

  def zip=(zip)
    @zip = zip
  end

  def last_name
    self.profile ? self.profile.last_name : @last_name
  end

  def last_name=(last_name)
    @last_name = last_name
  end

  def installed_apps
    self.oauth2_authorizations.map(&:client).map(&:oauth2_client_owner)
  end

  # def grouped_activity_logs
  #   logs = self.app_activity_logs
  #
  #   # create container for grouped logs that will be returned
  #   grouped_logs = {}
  #
  #   # iterate over current logs
  #   logs.each do |log|
  #     key = log.created_at.strftime('%B %e')
  #     if grouped_logs[key]
  #       grouped_logs[key] << log
  #     else
  #       grouped_logs[key] = [log]
  #     end
  #   end
  #
  #   grouped_logs
  # end

  def send_reset_password_confirmation
    # TODO commented out mailer
    #UserMailer.reset_password_confirmation(self.email).deliver
  end

  def scope_field_value(scope_name)
    field_name = scope_name.split('.').last
    if SCOPE_ATTRIBUTES.member?(field_name.to_sym)
      profile.send field_name
    else
      nil
    end
  end

  def set_values_from_scopes(scope_value_hash)
    scope_value_hash.each do |k, v|
      field_name = k.split('.').last
      self.profile.send "#{field_name}=", v
    end
    self.profile.save
  end

  def deauthorize_app(app)
    client_id = app.oauth2_client.id
    auth = self.oauth2_authorizations.where(:client_id => client_id)
    auth.destroy_all
  end

  private

  def create_profile
    self.profile = Profile.new(:first_name => @first_name, :last_name => @last_name, :zip => @zip) unless self.profile
  end

  def valid_email?
    self.email? && ValidatesEmailFormatOf::validate_email_format(self.email).nil?
  end

  def is_reconfirmation?
    self.unconfirmed_email.present?
  end

  def generate_uid
    self.uid = SecureRandom.uuid if self.uid.blank?
  end
end
