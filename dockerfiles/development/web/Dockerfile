# Use an official Ruby runtime as a parent image
FROM ruby:2.7.8

ENV NODE_ENV                development
ENV RAILS_ENV               development
ENV RACK_ENV                development
ENV ROOT_URL                0.0.0.0
ENV DATABASE_HOST           db
ENV DATABASE_PORT           5432
ENV DATABASE_USER           kudo_user
ENV DATABASE_PASSWORD       kudos
ENV DATABASE_NAME           kudo-o-matic_development
ENV DATABASE_URL            postgres://kudo_user:kudos@db:5432
ENV DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL true
ENV REDIS_URL               redis://redis:6379/0
ENV FRONTEND_ROOT_URL       http://localhost:9090
ENV MAIL_USERNAME           user@example.com 

# Install Node.js, yarn, Python, and build-essential
RUN apt-get update -qq && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y \
    gnupg \
    lsb-release \
    nodejs \
    yarnpkg  \
    python \
    build-essential

# Add the PostgreSQL repository GPG key
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg

# Add the PostgreSQL APT repository
RUN echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL client version 16
RUN apt-get update && apt-get install -y postgresql-client-16

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd -r app && useradd --no-log-init -r -m -g app app

USER app

WORKDIR /code

RUN mkdir /code/vendor

COPY --chown=app:app Gemfile      Gemfile
COPY --chown=app:app Gemfile.lock Gemfile.lock

# Install the required version of Bundler
RUN gem install bundler -v 2.2.15

# Install Ruby dependencies
RUN bundle config set force_ruby_platform true
RUN bundle install
