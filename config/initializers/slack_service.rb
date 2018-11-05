# frozen_string_literal: true

SLACK_IS_CONFIGURED = !Rails.env.test? && ENV["SLACK_ACCESS_TOKEN"].present?
