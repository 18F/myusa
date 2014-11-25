unless ENV['ELASTICACHE_ENDPOINT'].blank?
  endpoint    = ENV['ELASTICACHE_ENDPOINT'] + ':11211'
  elasticache = Dalli::ElastiCache.new(endpoint)
  config.cache_store = :dalli_store, elasticache.servers, {:expires_in => 1.day, :compress => true}
end
