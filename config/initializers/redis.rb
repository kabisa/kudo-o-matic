# Initialize Redis connection
$redis = Redis.new(url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
Rails.logger.info("Redis initializer is being loaded")

# Log Redis connection details
Rails.logger.info("REDIS_URL: #{ENV['REDIS_URL']}")

# Conditional block to prevent Redis commands during asset precompilation
unless ENV['ASSET_PRECOMPILE']
  # Log connection details if not in asset precompilation mode
  Rails.logger.info("Redis URL: #{$redis.client.options[:url]}")
  Rails.logger.info("SSL Params: #{$redis.client.options[:ssl_params]}")

  # Test Redis connection with a PING command
  begin
    Rails.logger.info("Redis PING: #{$redis.ping}")
  rescue StandardError => e
    Rails.logger.error("Redis connection failed: #{e.message}")
  end
end
