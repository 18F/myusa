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

  config.secret_key_base = ENV["SECRET_KEY_BASE"]
  config.devise_secret_key = ENV['DEVISE_SECRET_KEY']
  config.force_ssl = true
  config.sms_delivery_method = :twilio
  config.myusa_sender_email = ENV['SENDER_EMAIL']
  config.action_mailer.default_url_options = { host: ENV['APP_HOST'], protocol: 'https' }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:    ENV['SMTP_HOST'],
    port:       ENV['SMTP_PORT'],
    user_name:  ENV['SMTP_USER'],
    password:   ENV['SMTP_PASS'],
    authentication: 'plain',
    enable_starttls_auto: true
  }

  # For other environment config, see these initializers:
  # OMNIAUTH_*: devise.rb
  # ELASTICACHE_ENDPOINT: cache.rb
  # TWILIO_*: twilio.rb
end
