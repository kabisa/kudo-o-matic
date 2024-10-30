# Disable SSL verification as per Heroku requirements
# See https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-rails

Sidekiq.configure_server do |config|
  config.redis = { ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
end

Sidekiq.configure_client do |config|
  config.redis = { ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
end
