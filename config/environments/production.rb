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
    user_name:  ENV['SMTP_USER'],
    password:   ENV['SMTP_PASS'],
    authentication: 'plain',
    enable_starttls_auto: true
  }

  config.sms_sender_number = ENV['SMS_NUMBER']
  config.sms_delivery_method = :twilio

  # For some reason, trying to access these config parameters in the
  # initializers throws a method_missing, despite the configs set
  # above being totally OK. No idea why, need to investigate. -- Yoz
  config.twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
  config.devise_secret_key = ENV['DEVISE_SECRET_KEY']
  config.omniauth_google_app_id = ENV['OMNIAUTH_GOOGLE_APP_ID']
  config.omniauth_google_secret = ENV['OMNIAUTH_GOOGLE_SECRET']

  unless ENV['ELASTICACHE_ENDPOINT'].blank?
    endpoint    = ENV['ELASTICACHE_ENDPOINT'] + ":11211"
    elasticache = Dalli::ElastiCache.new(endpoint)
    config.cache_store = :dalli_store, elasticache.servers, {:expires_in => 1.day, :compress => true}
  end
end
