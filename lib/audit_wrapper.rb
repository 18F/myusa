class AuditWrapper

  def self.audit_create(klass, opts={})
    audit_wrapper = new(opts)

    klass.class_eval do
      has_many :user_action, as: :record
      after_create audit_wrapper
    end
  end

  def initialize(opts={})
    @user_method = opts[:user_method] if opts.has_key?(:user_method)
  end

  def audit(action, record)
    user = @user_method.present? ? record.send(@user_method) : record.user
    UserAction.create(user: user, record: record, action: action)
  end

  def after_create(record)
    audit('create', record)
  end
end
