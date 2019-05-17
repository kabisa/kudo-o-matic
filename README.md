# Kudos-o-Matic™

[![Travis Build Status](https://img.shields.io/travis/kabisa/kudo-o-matic.svg?style=flat-square)](https://travis-ci.org/kabisa/kudo-o-matic.svg?branch=master) [![GitHub release](https://img.shields.io/github/release/kabisa/kudo-o-matic.svg?style=flat-square)](https://github.com/kabisa/kudo-o-matic/releases) [![GitHub license](https://img.shields.io/github/license/kabisa/kudo-o-matic.svg?style=flat-square)](https://github.com/kabisa/kudo-o-matic/blob/master/LICENSE.md)
[![Maintainability](https://api.codeclimate.com/v1/badges/69d210539137c4dc5e06/maintainability)](https://codeclimate.com/github/kabisa/kudo-o-matic/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/69d210539137c4dc5e06/test_coverage)](https://codeclimate.com/github/kabisa/kudo-o-matic/test_coverage)

## Bug reports and feature requests

GitHub issues is closed, the [PivotalTracker project](https://www.pivotaltracker.com/n/projects/1993685) is the place to create new feature requests or bug reports. Please open all new issues in the icebox and use one of the [templates](https://www.pivotaltracker.com/help/articles/story_templates/) when opening a new issue.

## What is the Kudos-o-Matic?
The Kudo project originated from the wish to create common goals for people and teams who work on different projects in order to *strengthen the team spirit*, *collectively celebrate successes* and *ensure transparency* within an organization.

The Kudos-o-Matic was created to keep track of these goals and the progress towards it. 
Users can reward each other for good deeds by giving Kudos to each other and work together to achieve common goals in the form of Kudo-thresholds.


## Quick start guide
##### Prerequisites
To start using the Kudos-o-Matic, you'll need:
* [Ruby](https://www.ruby-lang.org/) >= 2.3.1
* [Ruby on Rails](http://rubyonrails.org/) >= 5.2
* [Redis](https://redis.io)
* [Bundler](http://bundler.io/)
* [PostgreSQL](https://www.postgresql.org/)
* [ImageMagick](https://www.imagemagick.org/)
* [Mailhog](https://github.com/mailhog/MailHog) (development only)

## Setup and Usage

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

##### Install Redis
* For Windows you can download it [here](https://github.com/rgl/redis/downloads) 

* For MacOS you can use Homebrew: `brew install redis`

##### Start Redis and Sidekiq
``` 
redis-server
bundle exec sidekiq -q default -q mailers
```

#### Database configuration
Copy default database configuration (change if needed)
```
cp config/database.yml.example config/database.yml
```

Database
```
rails db:create
rails db:migrate
rails db:seed
```

Copy environment variables. Following the dependency setup instructions below will help you set these variables.
``` 
cp env.example .env
```

Start Rails server 
```
rails s
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

## Entities

### Team
A *Team* is the tenant where you and your colleagues give and collect Kudos 

A *Team*:
* Has a name
* Has *0..1* active *KudosMeter*
* Has *0..n* *KudosMeter*
* Has *0..n* active *Goals*
* Has *0..n*  *Goals*
* Has *0..n* *Users*
* Has *0..n* *Posts*
* Has *0..n* *TeamMembers*
* Has *0..n* *TeamInvites*

### KudosMeter
A *KudosMeter* is the base of the Kudos-o-Matic system. It groups *Goals* together and connects them to *Posts*.  

A *KudosMeter*:
* Has a name
* Is the current *KudosMeter* or not
* Has *0..n* *Goals*
* Has *0..n* *Posts*


### Goal
A *Goal* depends on a *KudosMeter*. 
To set and see a *Goal* on the Kudo Meter you need to associate the *Goal* with the current *KudosMeter*.
A *Goal* is a common reward for the organization (for example: paintball) that will be organized if the defined Kudo threshold is exceeded.

A *Goal*:
* Has a name
* Has an amount of Kudos
* Has a date of achievement
* Belongs to *1* *KudosMeter*

### Post
A *Post* depends on a *KudosMeter*. 
A *User* can reward another *User* for a good deed by creating a Kudo *Post*.

A *Post*:
* Has an amount of Kudos
* Optionally has an image attachment (JPG, PNG or GIF)
* Has a message
* Has *1* sender (*User*)
* Has *1..n* receiver (*User*)
* Has *0..** *Votes*

### Vote
A *Vote* depends on a *Post* (votable) and a *User* (voter). 
A *User* can like and unlike *Posts*. 

A *Vote*:
* Belongs to *1* votable (*Post*)
* Belongs to *1* voter (*Voter*)
* Optionally has vote metadata

### User
A *User* can create a Kudo *Post* to reward another *User* for a good deed.
*Users* work together to achieve common Kudo *Goals*.

A *User*:
* Has a username
* Has an email address
* Optionally has admin rights (optional)
* Has preferences 
* Has *0..n* *Posts*
* Has *0..n* *Votes*

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

![Demo](https://kudo-o-matic-development.s3.amazonaws.com/Screenshot%202017-07-14%2015.17.38.png)
