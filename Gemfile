# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.5.4'

gem "activerecord-typedstore", "~> 1.1.1"
gem "actionpack", "~> 5.2", ">= 5.2.1"
gem "acts_as_votable", "~> 0.10.0"
gem "administrate", "~> 0.13.0"
gem "autoprefixer-rails", "~> 9.3", ">= 9.3.1"
gem 'aws-sdk-s3', '~> 1.23', '>= 1.23.1', require: false
gem "chronic", "~> 0.10.2"
gem "coffee-rails", "~> 4.2", ">= 4.2.2"
gem "devise", "~> 4.3"
gem 'devise-async', '~> 1.0'
gem "doorkeeper", "~> 4.3"
gem "delayed_paperclip", "~> 3.0.1"
gem "daemons"
gem "draper", "~> 3.0", ">= 3.0.1"
gem "fcm", "~> 0.0.2"
gem 'file_validators', '~> 2.3'
gem "friendly_id", "~> 5.2.4"
gem "google-id-token", "~> 1.4"
gem "graphql", "~> 1.8", ">= 1.8.10"
gem "graphql-batch", "~> 0.3.10"
gem 'graphql-guard', '~> 1.2', '>= 1.2.1'
gem 'graphql_playground-rails', '~> 2.0', '>= 2.0.1'
gem "haml-rails", "~> 1.0"
gem "jbuilder", "~> 2.0"
gem "json_web_token", "~> 0.3.5"
gem "jquery-rails", "~> 4.3.1"
gem "jquery-ui-rails", "~> 6.0.1"
gem "loofah", "~> 2.2.1"
gem 'mini_magick', '~> 4.9', '>= 4.9.2'
gem "nokogiri", "~> 1.8.5"
gem "omniauth-google-oauth2", "~> 0.5.2"
gem "omniauth-oauth2", "~> 1.3.1"
gem "omniauth-slack", "~> 2.3.0"
gem "paperclip", "~> 6.1"
gem "pg", "~> 0.18"
gem "premailer-rails", "~> 1.9.7"
gem "puma", "~> 3.0"
gem "rabl", "~> 0.13.1"
gem "rack-cors", "~> 1.0"
gem "rails", "~> 5.2", ">= 5.2.1"
gem "rails-controller-testing", "~> 1.0.2"
gem "rails-html-sanitizer", "~> 1.0.4"
gem "rails_autolink", "~> 1.1.6"
gem "railties", "~> 5.2", ">= 5.2.1"
gem 'rmagick', '~> 2.16'
gem "rubocop", "~> 0.60.0", require: false
gem "rubyzip", "~> 1.2.2", require: "zip"
gem "sentry-raven"
gem "settingslogic", "~> 2.0", ">= 2.0.9"
gem "scss_lint", "~> 0.54", require: false
gem 'sidekiq', '~> 5.2', '>= 5.2.3'
gem "slack-ruby-client", "~> 0.11.0"
gem "uglifier", "~> 3.2"

group :development, :staging, :test do
  # GraphQL UI similar to GraphiQL but better
  gem 'database_cleaner', '~> 1.7'
  gem 'faker', '~> 1.9', '>= 1.9.1'
end

group :development, :test do
  gem 'dotenv-rails', '~> 2.5'
  gem 'factory_bot_rails', '~> 4.8', '>= 4.8.2'
  gem 'graphlient', '~> 0.3.3'
  gem 'pry', '~> 0.11.3'
end

group :test do
  gem 'rubocop-rspec', '~> 1.30'
  gem 'rspec-rails', '~> 3.8'
  gem 'rspec-graphql_matchers', '~> 0.7.1'
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.2'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'timecop', '~> 0.9.1'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Pry as rails console
  gem 'pry-rails'

  gem 'rails-erd'
  gem 'railroady'
end

group :production do
  gem 'rails_12factor', '~> 0.0.3'
end
