# Initialize Redis connection
$redis = Redis.new(url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
Rails.logger.info("Redis initializer is being loaded")

# Log Redis connection details
Rails.logger.info("REDIS_URL: #{ENV['REDIS_URL']}")

Rails.logger.info("SSL Params: #{$redis.client.options[:ssl_params]}")