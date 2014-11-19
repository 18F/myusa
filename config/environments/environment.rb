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

  env_config = YAML.load_file(Rails.root.join('config/environment.yml'))

  memcached_hosts = environment_config['elasticache']['endpoint']
  if memcached_hosts && !memcached_hosts[0].blank?
    config.cache_store = :dalli_store, *memcached_hosts
  end

  unless env_config['elasticache'].nil? || env_config['elasticache']['endpoint'].nil?
    endpoint    = environment_config['elasticache']['endpoint'] + ':11211'
    elasticache = Dalli::ElastiCache.new(endpoint)

    config.cache_store = :dalli_store, elasticache.servers,
                         {:expires_in => 1.day, :compress => true}
  end

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: env_config['app']['url'] }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:    'email-smtp.us-east-1.amazonaws.com',
    port:       '587',
    user_name:  Rails.application.secrets.aws_ses_username,
    password:   Rails.application.secrets.aws_ses_password,
    authentication: 'plain',
    enable_starttls_auto: true
  }

  config.sms_sender_number = '+12407433320'
  config.sms_delivery_method = :twilio
end
