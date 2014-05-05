class Profile < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  belongs_to :user
  validates_format_of :zip, :with => /\A\d{5}?\z/, :allow_blank => true, :message => "should be in the form 12345"
  validates_format_of :phone, :with => /\A\d+\z/, :allow_blank => true
  validates_length_of :phone, :maximum => 10
  validates_format_of :mobile, :with => /\A\d+\z/, :allow_blank => true
  validates_length_of :mobile, :maximum => 10
  
  after_validation :set_errors
  
  PROFILE_FIELDS = [:title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired]
  PROFILE_METHODS = [:email, :phone_number, :mobile_number]
  
#  attr_accessible :title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :phone_number, :mobile_number, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired, :as => [:default, :admin]
#  attr_accessible :user_id, :phone, :mobile, :as => :admin
  
  def name
    (first_name.blank? or last_name.blank?) ? nil : [first_name, last_name].join(" ")
  end
  
  def phone_number=(value)
    self.phone = normalize_phone_number(value)
  end
  
  def phone_number
    pretty_print_phone(self.phone)
  end
  
  def mobile_number=(value)
    self.mobile = normalize_phone_number(value)
  end
  
  def mobile_number
    pretty_print_phone(self.mobile)
  end

  def print_gender
    self.gender.blank? ? nil : self.gender.capitalize
  end
  
  def print_marital_status
    self.marital_status.blank? ? nil : self.marital_status.titleize
  end

  def as_json(options = {})
    fields, methods = [], []
    if (options[:scope_list] and options[:scope_list].include?("profile")) or options[:scope_list].nil?
      fields += PROFILE_FIELDS
      methods += PROFILE_METHODS.collect{|method| method.to_s}
    else
      profile_scope_list = options[:scope_list].collect{|scope| scope.starts_with?('profile') ? scope.split('.').last : nil}.compact
      PROFILE_FIELDS.each{|field| fields << field if profile_scope_list.include?(field.to_s)}
      PROFILE_METHODS.each{|method| methods << method.to_s if profile_scope_list.include?(method.to_s)}
    end
    super(:only => fields, :methods => methods)
  end
    
  def to_schema_dot_org_hash(scope_list = [])
    profile_as_json = self.as_json({:scope_list => scope_list})
    {"email" => profile_as_json["email"], "givenName" => profile_as_json["first_name"], "additionalName" => profile_as_json["middle_name"], "familyName" => profile_as_json["last_name"], "homeLocation" => {"streetAddress" => [profile_as_json["address"], profile_as_json["address2"]].reject{|s| s.blank? }.join(','), "addressLocality" => profile_as_json["city"], "addressRegion" => profile_as_json["state"], "postalCode" => profile_as_json["zip"]}, "telephone" => profile_as_json["phone"], "gender" => profile_as_json["gender"] }
  end
  
  def email=(value)
    @email = value
  end
  
  def email
    defined?(@email) ? @email : (self.user ? self.user.email : nil)
  end
    
  def filtered_profile(scope_list=[])
    field_scope_mapping = {
      :title          => 'profile.title', 
      :email          => 'profile.email',
      :first_name     => 'profile.first_name',
      :middle_name    => 'profile.middle_name',
      :last_name      => 'profile.last_name',
      :suffix         => 'profile.suffix', 
      :address        => 'profile.address', 
      :address2       => 'profile.address2', 
      :city           => 'profile.city', 
      :state          => 'profile.state', 
      :zip            => 'profile.zip', 
      :phone_number   => 'profile.phone_number',
      :mobile_number  => 'profile.mobile_number',
      :gender         => 'profile.gender', 
      :marital_status => 'profile.marital_status', 
      :is_parent      => 'profile.is_parent', 
      :is_retired     => 'profile.is_retired', 
      :is_veteran     => 'profile.is_veteran', 
      :is_student     => 'profile.is_student'
    }

    empty_copy = self.clone
    field_scope_mapping.each do |field, scope|
      empty_copy.send("#{field}=", nil) unless scope_list.member?(scope)
    end
    empty_copy
  end
  
  
  private
  
  def pretty_print_phone(number)
    number_to_phone(number)
  end
  
  def normalize_phone_number(number)
    number.gsub(/[- \(\)]/, '') if number
  end
  
  def set_errors
    self.errors.add(:phone_number, self.errors.delete(:phone)) unless self.errors[:phone].blank?
    self.errors.add(:mobile_number, self.errors.delete(:mobile)) unless self.errors[:mobile].blank?
  end 
end