$redis = Redis.new(url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
Rails.logger.info("Redis initializer is being loaded")
Rails.logger.info("Redis URL: #{$redis.client.options[:url]}")
Rails.logger.info("SSL Params: #{$redis.client.options[:ssl_params]}")
begin
  Rails.logger.info("Redis PING: #{$redis.ping}")
rescue StandardError => e
  Rails.logger.error("Redis connection failed: #{e.message}")
end
Rails.logger.info("REDIS_URL: #{ENV['REDIS_URL']}")
