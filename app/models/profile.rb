class Profile < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ::Encryption

  belongs_to :user
  validates_format_of :zip, :with => /\A\d{5}?\z/, :allow_blank => true, :message => "should be in the form 12345"
  validates_format_of :phone, :with => /\A\d+\z/, :allow_blank => true
  validates_length_of :phone, :maximum => 10
  validates_format_of :mobile, :with => /\A\d+\z/, :allow_blank => true
  validates_length_of :mobile, :maximum => 10

  has_one :mobile_confirmation #, :dependent => :destroy

  after_validation :set_errors

  FIELDS = [:title, :first_name, :middle_name, :last_name, :suffix, :address,
    :address2, :city, :state, :zip, :gender, :marital_status, :is_parent,
    :is_student, :is_veteran, :is_retired]
  METHODS = [:email, :phone_number, :mobile_number]

  ENCRYPTED_FIELDS = FIELDS + [:mobile, :phone]
  ENCRYPTED_FIELDS.map { |attrib| attr_encrypted attrib.to_sym, key: :key, marshal: true }

  def self.scopes
    (FIELDS + METHODS).map {|f| "profile.#{f}"}
  end

  def self.attribute_from_scope(scope)
    parsed_scope = scope.split('.')
    return nil unless parsed_scope.first == 'profile'
    field = parsed_scope.second
    (FIELDS + METHODS).select {|attribute| attribute.to_s == field }.first
  end

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
      fields += FIELDS
      methods += METHODS.collect{|method| method.to_s}
    else
      profile_scope_list = options[:scope_list].collect{|scope| scope.starts_with?('profile') ? scope.split('.').last : nil}.compact
      FIELDS.each{|field| fields << field if profile_scope_list.include?(field.to_s)}
      METHODS.each{|method| methods << method.to_s if profile_scope_list.include?(method.to_s)}
    end
    options[:only], options[:methods] = fields, methods

    attribute_names = attributes.keys.map {|k| k.gsub(Profile.encrypted_column_prefix, '')}

    if only = options[:only]
      attribute_names &= Array(only).map(&:to_s)
    elsif except = options[:except]
      attribute_names -= Array(except).map(&:to_s)
    end

    hash = {}
    attribute_names.each { |n| hash[n] = read_attribute_for_serialization(n) }

    Array(options[:methods]).each { |m| hash[m.to_s] = send(m) if respond_to?(m) }

    serializable_add_includes(options) do |association, records, opts|
      hash[association.to_s] = if records.respond_to?(:to_ary)
        records.to_ary.map { |a| a.serializable_hash(opts) }
      else
        records.serializable_hash(opts)
      end
    end

    hash
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

  alias_method :'is_parent_enc=', :'is_parent='
  def is_parent=(parent_val)
    self.is_parent_enc = make_boolean(parent_val)
  end

  alias_method :'is_student_enc=', :'is_student='
  def is_student=(student_val)
    self.is_student_enc = make_boolean(student_val)
  end

  alias_method :'is_veteran_enc=', :'is_veteran='
  def is_veteran=(veteran_val)
    self.is_veteran_enc = make_boolean(veteran_val)
  end

  alias_method :'is_retired_enc=', :'is_retired='
  def is_retired=(retired_val)
    self.is_retired_enc = make_boolean(retired_val)
  end

  def filtered_profile(scope_list = [])
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

  def make_boolean(val)
    return nil if val.to_s.blank?
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(val)
  end

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
