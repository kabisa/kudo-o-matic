# Kudos-o-Matic™

[![Rails test and deploy](https://github.com/kabisa/kudo-o-matic/workflows/Rails%20test%20and%20deploy/badge.svg)](https://github.com/kabisa/kudo-o-matic/actions)
[![Maintainability](https://api.codeclimate.com/v1/badges/69d210539137c4dc5e06/maintainability)](https://codeclimate.com/github/kabisa/kudo-o-matic/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/69d210539137c4dc5e06/test_coverage)](https://codeclimate.com/github/kabisa/kudo-o-matic/test_coverage)

## Bug reports and feature requests

GitHub issues is closed, the [PivotalTracker project](https://www.pivotaltracker.com/n/projects/1993685) is the place to create new feature requests or bug reports. Please open all new issues in the icebox and use one of the [templates](https://www.pivotaltracker.com/help/articles/story_templates/) when opening a new issue.

## What is the Kudos-o-Matic?
The Kudo project originated from the wish to create common goals for people and teams who work on different projects in order to *strengthen the team spirit*, *collectively celebrate successes* and *ensure transparency* within an organization.

The Kudos-o-Matic was created to keep track of these goals and the progress towards it. 
Users can reward each other for good deeds by giving Kudos to each other and work together to achieve common goals in the form of Kudo-thresholds.


## Quick start guide
### Prerequisites
To start using the Kudos-o-Matic, you'll need:

* [Ruby](https://www.ruby-lang.org/) (consult [.ruby-version](.ruby-version) or [Gemfile](Gemfile) for the proper version)
* [Ruby on Rails](http://rubyonrails.org/)  (consult [Gemfile](Gemfile) for the proper version)
* [Redis](https://redis.io)
* [Bundler](http://bundler.io/)
* [PostgreSQL](https://www.postgresql.org/)
* [ImageMagick](https://www.imagemagick.org/)
* [Mailhog](https://github.com/mailhog/MailHog) (development only)

### Setup and Usage

#### Ruby and Ruby version managers

By using a Ruby version manager (such as [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/)), you can easily switch between different Ruby versions and avoid conflicts that can occur when different versions use different versions of gems. You can pick your version manager of choice.

#### Dependencies

First, make sure you install bundler:

```
gem install bundler
```

Then, install dependencies:

```
bundle install
```

#### Redis

* For Windows you can download it [here](https://github.com/rgl/redis/downloads) 
* For MacOS you can use Homebrew: `brew install redis`

#### Environment variables

Copy environment variables. Following the dependency setup instructions below will help you set these variables.

``` 
cp env.example .env
```

#### Database configuration

Copy default database configuration (change if needed)

```
cp config/database.yml.example config/database.yml
```

#### Database

Create the databases and initialize it with the seed data.  
The [corresponding script](db/seeds.db) requires Redis to be up and running, so make sure you start this first.

```
redis-server
bin/rails db:setup
```

### Usage

``` 
redis-server
bin/sidekiq -q default -q mailers
bin/rails s
```

#### What's next?
* Your GraphQL endpoint will be listening on '<http://localhost:3000/graphql>'.
* You can view your Kudos-o-Matic playground at '<http://localhost:3000/graphql/playground>'.
* You can set up your Kudos-o-Matic front-end by following the instructions on '<https://github.com/kabisa/kudos-frontend>'

## Set up dependencies (optional)
Congratulations, you did just set up the Kudos-o-Matic!  
You can optionally set up the dependencies listed below to get the most out of your Kudos-o-Matic.

### Amazon AWS S3 setup
Follow these instructions to setup the Amazon AWS S3 cloud storage service for images attached to Kudo posts:
* [Create an AWS S3 account](https://aws.amazon.com/resources/create-account/).
* Setup a Amazon S3 Bucket.
* Set the `AWS_S3_HOST_NAME`, `AWS_S3_REGION`, `AWS_S3_BUCKET`, `AWS_S3_BUCKET` and `AWS_SECRET_ACCESS_KEY` environment variables.
* Restart the server.

### Mail setup
The Kudos-o-Matic can automatically send mail notifications when the following events occur:
* When a user joins the Kudos-o-Matic platform.
* When a user receives Kudos (only this user will receive the notification).
* When a Kudo goal is reached.
* Weekly summary mail.
* User account related emails (confirmation, password reset, etc.)

To use Mailhog for local usage follow the instructions on [their GitHub repository](https://github.com/mailhog/MailHog)

You can also update the configuration (`development.rb`) if you don't want to use Mailhog. Set and use the `MAIL_USERNAME`, `MAIL_PASSWORD` and `MAIL_ADDRESS` environment variables for this.

### Slack 
See [here](docs/SLACK_INTEGRATION.md).

### CI and deployment
The project is build using [GitHub actions](https://github.com/kabisa/kudo-o-matic/actions) and deployed to [Heroku](https://dashboard.heroku.com/teams/kabisa/apps).

Every commit to the develop branch is deployed to [staging](https://dashboard.heroku.com/apps/kudo-o-matic-staging)

Every commit to the master branch is deployed to [production](https://dashboard.heroku.com/apps/kudo-o-matic-production) 

## Entities

A diagram of the models is available [here](docs/erd.svg).

### KudosMeter
A *KudosMeter* is the base of the Kudos-o-Matic system. It groups *Goals* together and connects them to *Posts*.  

### Team
A *Team* is the tenant where you and your colleagues give and collect Kudos 

### Goal
A *Goal* depends on a *KudosMeter*. 
To set and see a *Goal* on the Kudo Meter you need to associate the *Goal* with the current *KudosMeter*.
A *Goal* is a common reward for the organization (for example: paintball) that will be organized if the defined Kudo threshold is exceeded.

### Post
A *Post* depends on a *KudosMeter*. 
A *User* can reward another *User* for a good deed by creating a Kudo *Post*.

### Vote
A *Vote* depends on a *Post* (votable) and a *User* (voter). 
A *User* can like and unlike *Posts*. 

### User
A *User* can create a Kudo *Post* to reward another *User* for a good deed.
*Users* work together to achieve common Kudo *Goals*.

## How to contribute?
* [Fork the repository](https://github.com/kabisa/kudo-o-matic/fork).
* Create your feature branch (`git checkout -b my-new-feature`).
* Commit your changes (`git commit -am 'Add some new feature'`).
* Push to the branch (`git push origin my-new-feature`).
* [Create a new Pull Request](https://github.com/kabisa/kudo-o-matic/pulls).

## Did you find a bug?
* [Ensure the bug was not already reported](https://github.com/kabisa/kudo-o-matic/issues).
* If you are unable to find an open issue addressing the problem, [open a new one](https://github.com/kabisa/kudo-o-matic/issues/new).   
* Be sure to include a title and a clear description, as much relevant information as possible, 
and a code example or an executable test case demonstration of the expected behavior that is not occurring. 

## License
Copyright (c) 2016-2019 [Kabisa](https://www.kabisa.nl/). See [license](https://github.com/kabisa/kudo-o-matic/blob/develop/LICENSE.md) for details.
