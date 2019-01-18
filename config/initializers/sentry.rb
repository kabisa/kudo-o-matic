# frozen_string_literal: true

# make sure that Rail's log filtering items are not sent to Sentry
Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end