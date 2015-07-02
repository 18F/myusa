require 'csv'
require 'rubygems'
require 'datashift'
require 'fileutils'

class DatabaseDumper
  EXPORT_DIR = Rails.root.join("db", "backup")

  def self.ensure_dir
    DataShift::require_libraries
    require 'csv_exporter'
    require 'csv_loader'

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
    save_csv(AuthenticationToken, "authentication_tokens")
    save_csv(Authentication, "authentications")
    save_csv(Doorkeeper::Application, "oauth_applications")
    save_csv(Authorization, "authorizations")
    save_csv(Feedback, "feedbacks")
    save_csv(Notification, "notifications")
    save_csv(Doorkeeper::AccessGrant, "oauth_access_grants")
    save_csv(Doorkeeper::AccessToken, "oauth_access_tokens")
    # fix me save_csv(Doorkeeper::Scope.all, "oauth_scopes")  FIXME
    save_csv(Role, "roles")
    save_csv(SmsCode, "sms_codes")
    save_csv(Task, "tasks")
    save_csv(TaskItem, "task_items")
    save_csv(UnsubscribeToken, "unsubscribe_tokens")
    puts "Export complete"
  end

  def self.save_csv(klass, filename)
    records = klass.all
    exporter = DataShift::CsvExporter.new(csv_path(filename))
    exporter.export(records)
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
        import_csv(AuthenticationToken, "authentication_tokens")
        import_csv(Authentication, "authentications")
        import_csv(Doorkeeper::Application, "oauth_applications")
        import_csv(Authorization, "authorizations")
        import_csv(Feedback, "feedbacks")
        import_csv(Notification, "notifications")
        import_csv(Doorkeeper::AccessGrant, "oauth_access_grants")
        import_csv(Doorkeeper::AccessToken, "oauth_access_tokens")
        # fix me save_csv(Doorkeeper::Scope.all, "oauth_scopes")  FIXME
        import_csv(Role, "roles")
        import_csv(SmsCode, "sms_codes")
        import_csv(Task, "tasks")
        import_csv(TaskItem, "task_items")
        import_csv(UnsubscribeToken, "unsubscribe_tokens")
        puts "Import complete"
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

    def self.import_csv(klass, filename)
      klass.delete_all
      path = csv_path(filename)

      if File.exists?(path)
        loader = DataShift::CsvLoader.new(klass)
        loader.perform_csv_load(path, :dummy => true)
      else
        puts "No dump found for #{filename}. Assuming that means no records..."
      end
    end
end
