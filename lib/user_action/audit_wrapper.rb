class AuditWrapper
  def initialize(opts)
    @action = opts[:action] if opts.has_key?(:action)
  end

  def after_create(record)
    audit(@action || 'create', record)
  end

  def after_update(record)
    audit(@action || 'update', record)
  end

  def before_destroy(record)
    audit(@action || 'destroy', record)
  end

  private

  def audit(action, record)
    ::UserAction.create(record: record, action: action)
  end
end
