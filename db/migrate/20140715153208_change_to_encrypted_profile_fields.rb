class ChangeToEncryptedProfileFields < ActiveRecord::Migration
  class EncryptedProfile < ActiveRecord::Base
    self.table_name = 'profiles'
    include ::Encryption
    FIELDS = [:title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired]
    ENCRYPTED_FIELDS = FIELDS + [:mobile, :phone]
    ENCRYPTED_FIELDS.map { |attrib| attr_encrypted attrib.to_sym, key: :key, marshal: true }
    # attr_accessible :title, :first_name, :middle_name, :last_name, :suffix, :address, :address2, :city, :state, :zip, :phone_number, :mobile_number, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired, :as => [:default, :admin]
    # attr_accessible :user_id, :phone, :mobile, :as => :admin
  end
  
  def up
    add_encrypted_columns
    EncryptedProfile.connection.schema_cache.clear!
    EncryptedProfile.reset_column_information
  end

  def down
    remove_encrypted_columns
  end

private
  
  def encrypted_fields
    ChangeToEncryptedProfileFields::EncryptedProfile::FIELDS + [:phone, :mobile]
  end

  def add_encrypted_columns
    # add column names with 'encrypted_' prefix
    encrypted_fields.each { |field| add_column :profiles, "#{EncryptedProfile.encrypted_column_prefix}#{field}", :string }
  end

  def remove_encrypted_columns
    # remove column names without 'encrypted_' prefix
    encrypted_fields.each { |field| remove_column :profiles, "#{EncryptedProfile.encrypted_column_prefix}#{field}" } 
  end
end
