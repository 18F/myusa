require 'csv'
require 'rubygems'
require 'fileutils'

class DatabaseDumper
  EXPORT_DIR = Rails.root.join("db", "backup")

  def self.ensure_dir
    FileUtils.mkdir_p(EXPORT_DIR)
  end

  def self.cleanup
    FileUtils.rm_rf(EXPORT_DIR)
  end

  def self.csv_path(name)
    File.join(EXPORT_DIR, "#{name}.csv")
  end

  def self.export_all_csvs
    ensure_dir
    save_profiles_csv

    [AuthenticationToken, Authentication, Doorkeeper::Application, Authorization, Feedback, Notification, Doorkeeper::AccessGrant,
     Doorkeeper::AccessToken, Role, SmsCode, Task, TaskItem, UnsubscribeToken].each do |klass|
      save_csv(klass)
    end
    #puts "Export complete"
  end

  def self.save_csv(klass)
    return unless klass.count > 0    

    column_names = klass.columns.map(&:name)
    table_name = klass.table_name

    CSV.open(csv_path(table_name), "w") do |csv|
      csv << column_names

      klass.find_each do |x|
        csv << column_names.map {|c| x.read_attribute(c) }  # after it's been type-cast
      end
    end
  end

  def self.save_profiles_csv
    CSV.open(csv_path("profiles"), "w") do |csv|
      csv << %w(user_id created_at updated_at title first_name middle_name last_name suffix address address2 city state zip gender marital_status is_parent is_student is_veteran is_retired phone mobile)

      Profile.find_each do |p|
        csv << [
          p.user_id,
          p.created_at,
          p.updated_at,
          p.title,
          p.first_name,
          p.middle_name,
          p.last_name,
          p.suffix,
          p.address,
          p.address2,
          p.city,
          p.state,
          p.zip,
          p.gender,
          p.marital_status,
          p.is_parent? ? 1 : 0,
          p.is_student? ? 1 : 0,
          p.is_veteran? ? 1 : 0,
          p.is_retired? ? 1 : 0,
          p.phone,
          p.mobile
        ]
      end
    end
  end

    def self.import_all_csvs
      ensure_dir
      ActiveRecord::Base.transaction do
        import_profiles
        
        [AuthenticationToken, Authentication, Doorkeeper::Application, Authorization, Feedback, Notification,
         Doorkeeper::AccessGrant, Doorkeeper::AccessToken, Role, SmsCode, Task, TaskItem, UnsubscribeToken].each do |klass|
          import_csv(klass)
        end
        #puts "Import complete"
      end
    end

    def self.import_profiles
      Profile.delete_all

      CSV.foreach(csv_path("profiles"), :headers => true) do |row|
        p = Profile.new(:user_id => row["user_id"], :created_at => row["created_at"], :updated_at => row["updated_at"])

        Profile::ENCRYPTED_FIELDS.each do |f|
          f = f.to_s   # CSV row hashmap is not indifferent about symbols vs. hash keys
          p.send("#{f}=", row[f])
        end

        p.save!
      end
    end

    def self.import_csv(klass)
      klass.delete_all 
      table_name = klass.table_name
      path = csv_path(table_name)

      if File.exists?(path)
        CSV.foreach(path, :headers => true) do |row|
          klass.create row.to_h
        end
      else
#        puts "No dump found for #{filename}. Assuming that means no records..."
      end
    end
end
