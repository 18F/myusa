class ConvertEncryptedProfileFields < ActiveRecord::Migration
  class EncryptedProfile < ActiveRecord::Base
    self.table_name = 'profiles'
    include ::Encryption
    FIELDS = [:title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired]
    ENCRYPTED_FIELDS = FIELDS + [:mobile, :phone]
    ENCRYPTED_FIELDS.map { |attrib| attr_encrypted attrib.to_sym, key: :key, marshal: true }
    # attr_accessible :title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :phone_number, :mobile_number, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired, :as => [:default, :admin]
    # attr_accessible :user_id, :phone, :mobile, :as => :admin
    
    def set_attribute(a,b)
      write_attribute(a,b)
    end
  end

  def up
    EncryptedProfile.all.each do |profile|
      encrypt_fields(profile)
      profile.save!
    end
    
    remove_unencrypted_columns
  end

  def down
    add_unencrypted_columns
    EncryptedProfile.connection.schema_cache.clear!
    EncryptedProfile.reset_column_information
    
    EncryptedProfile.all.each do |profile|
      decrypt_fields(profile)
      profile.save!
    end
  end

  private

  def encrypt_fields(profile)
    encrypted_fields.each do |field|
      profile.send("#{field}=".to_sym, profile.read_attribute(field))
    end
    profile
  end

  def decrypt_fields(profile)
    encrypted_fields.each do |field|
      profile.set_attribute(field, profile.send(field.to_sym))
    end
    profile
  end
  
  def encrypted_fields
    ConvertEncryptedProfileFields::EncryptedProfile::FIELDS + [:phone, :mobile]
  end

  def add_unencrypted_columns
    # restore column names without 'encrypted_' prefix
    encrypted_fields.each { |field| add_column :profiles, field, :string }
  end

  def remove_unencrypted_columns
    # remove column names without 'encrypted_' prefix
    encrypted_fields.each { |field| remove_column :profiles, field }
  end
end
