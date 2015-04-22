Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = false
  config.assets.compile = true
  config.assets.digest = true
  config.assets.version = '1.0'
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false

  config.myusa_sender_email = ENV['SENDER_EMAIL']
  config.action_mailer.default_url_options = { host: ENV['APP_HOST'] }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:    ENV['SMTP_HOST'],
    port:       ENV['SMTP_PORT'],
    user_name:  Rails.application.secrets.smtp_user,
    password:   Rails.application.secrets.smtp_pass,
    authentication: 'plain',
    enable_starttls_auto: true
  }

  config.sms_sender_number = ENV['SMS_NUMBER']
  config.sms_delivery_method = :twilio

  unless ENV['ELASTICACHE_ENDPOINT'].blank?
    endpoint    = ENV['ELASTICACHE_ENDPOINT'] + ":11211"
    elasticache = Dalli::ElastiCache.new(endpoint)
    config.cache_store = :dalli_store, elasticache.servers, {:expires_in => 1.day, :compress => true}
  end

  # Logstasher
  config.logstasher.enabled = true
  config.logstasher.suppress_app_log = false
  config.logstasher.source = 'myusa'
  config.logstasher.backtrace = true
end