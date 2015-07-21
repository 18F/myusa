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

    [AuthenticationToken, Authentication, Doorkeeper::Application, Authorization, Feedback,
     Notification, Doorkeeper::AccessGrant, Doorkeeper::AccessToken, Role, SmsCode, Task,
     TaskItem, UnsubscribeToken, UserAction].each do |klass|
      save_csv(klass)
    end

    save_csv(User, methods: [:role_ids])
  end

  def self.save_csv(klass, options = {})
    return unless klass.count > 0  

    column_names = klass.columns.map(&:name)
    csv_columns = column_names
    csv_columns += options[:methods] if options[:methods]

    table_name = klass.table_name

    CSV.open(csv_path(table_name), "w") do |csv|
      csv << csv_columns

      klass.find_each do |x|
        # this is writing out the typecast Rails versions of the database columns
        row = column_names.map { |c| x.read_attribute(c) }
        row += options[:methods].map { |c| x.send(c).join(",") } if options[:methods]
        csv << row
      end
    end
  end

  def self.save_profiles_csv
    CSV.open(csv_path("profiles"), "w") do |csv|
      csv << %w(id user_id created_at updated_at title first_name middle_name last_name suffix address address2 city state zip gender marital_status is_parent is_student is_veteran is_retired phone mobile)

      Profile.find_each do |p|
        csv << [
          p.id,
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
      [AuthenticationToken, Authentication, Doorkeeper::Application, Authorization, Feedback,
       Notification, Doorkeeper::AccessGrant, Doorkeeper::AccessToken, Role, SmsCode, Task,
       TaskItem, UnsubscribeToken].each do |klass|
        import_csv(klass)
      end

      import_users
      import_profiles
    end
  end

  def self.import_profiles
    Profile.delete_all

    CSV.foreach(csv_path("profiles"), headers: true) do |row|
      p = Profile.new(user_id: row["user_id"], created_at: row["created_at"], updated_at: row["updated_at"])
      p.id = row["id"]   # necessary to copy over the row

      Profile::ENCRYPTED_FIELDS.each do |f|
        f = f.to_s   # CSV row hashmap is not indifferent about symbols vs. hash keys
        p.send("#{f}=", row[f])
      end

      p.save!
    end
  end

  def self.import_users
    User.delete_all
    path = csv_path("users")
    return unless File.exist?(path)

    CSV.foreach(path, headers: true) do |row|
      attr_hash = row.to_h
      role_ids = attr_hash.delete("role_ids")

      u = User.create(attr_hash)
      u.roles.clear
      
      role_ids.split(/,/).each do |role_id|
        r = Role.find(role_id)
        u.roles << r
      end
    end
  end

  def self.import_csv(klass)
    klass.delete_all
    table_name = klass.table_name
    path = csv_path(table_name)

    if File.exist?(path)
      CSV.foreach(path, headers: true) do |row|
        klass.create row.to_h
      end
    end
  end
end
