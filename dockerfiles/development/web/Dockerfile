# Use an official Ruby runtime as a parent image
FROM ruby:2.7.0

ENV NODE_ENV                development
ENV RAILS_ENV               development
ENV RACK_ENV                development
ENV ROOT_URL                0.0.0.0
ENV DATABASE_NAME           kudo-o-matic_development
ENV DATABASE_URL            postgres://kudo_user:kudos@db:5432

# Install Node.js, npm, Yarn, Python, and build-essential
RUN apt-get update -qq && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y python build-essential 

RUN groupadd -r app && useradd --no-log-init -r -m -g app app

USER app

WORKDIR /code

RUN mkdir /code/vendor

COPY --chown=app:app Gemfile      Gemfile
COPY --chown=app:app Gemfile.lock Gemfile.lock

# Install the required version of Bundler
RUN gem install bundler -v 2.2.15

# Install Ruby dependencies
RUN bundle install
