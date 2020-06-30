# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Don't send Slack announcement when creating a post via emoji

### Fixed
- Url in mails referencing the backend url instead of the frontend url

## [4.2.1]
### Fixed
- duplicate team memberships

## [4.2.0]
### Added
- Slack integration 
- Mutation to set the active kudometer

### Fixed
- Only fetch posts for the active kudometer
- Virtual users are no longer being duplicated

## [4.1.1]
### Added
- Clear error message when team invite already exists

### Fixed
- Raise error when team invite already exists

## [4.1.0]
### Added
- Check if there is at least 1 team admin per team on team member update or destroy
- Update (vulnerable) dependencies

### Removed
- Method to remove team members since removing the invites shouldn't be necessary

## [4.0.0]
### Added
- GraphQL API
- New app for web and mobile
    - [Web app](https://kudos.kabisa.io)
    - [Google Play Store](https://play.google.com/store/apps/details?id=nl.kabisa.kudometer)
    - [Apple App Store](https://itunes.apple.com/nl/app/kudometer/id1445165688?mt=8)
- Give Kudos to multiple users at once (multiple receivers)
- Improved test coverage of the backend (from 49% to 92%)
- Maintability improved (from D to A)

### Changed
- Model name changed from Transaction to Post
- Model name changed from Balance to KudosMeter
- Active KudosMeter is set on team instead of on KudosMeter itself
- Activities migrated to Message on Post
- Migrated from Paperclip to Rails ActiveStorage for images
- Non-existing receivers are now treated as 'virtual users'

### Removed
- Rails webviews
- REST API for mobile app
- Slack integration (temporarily)
- Firebase integration
- Editing a post (temporarily)
- Adding images to a post (temporarily)
- User notification preferences (temporarily)
- User data export (temporarily)

## [3.4.0]
### Added
- RSS feed token for team and rss feed per team

## [3.3.0]
### Added
- Users can get invited to team without needing an account first
- Added guidelines per team
- Added helpcenter
- Edit/Delete your transactions

### Changed
- Bug fixes
- Improved profile menu
- Improved team manage page

## [3.2.0]
### Added
- Users can now create teams
- After team creation, a balance, some goals, a company user and example transaction are created
- Teams are accessible by their slug, e.g. /kabisa
- Users can only access teams they are a member of
- Page for choosing a team
- Users with only 1 team automatically get redirected to their team
- GDPR account restriction feature
- GDPR data viewing feature
- GDPR data export feature
- New API version (V2) with Doorkeeper integration
- Cron jobs for generating and cleaning up exports
- Registration form with email confirmation
- Login form
- Reset password form
- Unlock account form
- Edit account form

### Changed
- Feed now shows the transactions, balances, goals, users and statistics of the current team

### Removed
- Google login in favor of a regular login and registration form

## [3.1.0] - 2018-01-10
### Added
- Receive notifications in the ₭udo-o-Mobile app when you receive ₭udos
- Receive notifications in the ₭udo-o-Mobile app when a ₭udo goal is reached
- Receive a weekly ₭udo reminder in the ₭udo-o-Mobile app
- REST API functionality for retrieving ₭udo-o-Matic usage statistics and historical data

### Changed
- Made ₭udo-o-Matic notifications less obtrusive in the Slack feed
- Fixed several Slack-related bugs and improved stability

## [3.0.0] - 2017-12-04
### Added
- Receive email when you receive Kudos
- Receive email when a Kudo goal is reached
- Receive a weekly Kudo summary email
- Receive personalized Slack notifications and reminders
- Give Kudos with the /kudo command in Slack
- Give Kudos by adding the :kudo: reactji to a message of a Kudo-o-Matic user in Slack
- Like Kudo transactions using the like button in Slack
- Settings page for connecting with Slack and configuring mail preferences
- Single Kudo transaction page, used for sharing transactions by URL
- Button on the homepage for navigating back to the top
- User deactivation system
- Implemented checks that prevent removing important data entries
- REST API for the upcoming Kudo-o-Mobile app
- Asynchronous image uploads and Slack communication

## [2.0.1] - 2017-07-15
### Changed
- Fixed browser related issues in IE, Safari and Firefox

## [2.0.0] - 2017-07-04
### Added
- Like button for transactions
- Emoji's

### Changed
- New application design
- Multiple goals are now visible in the Kudo meter
- Minor bug fixes

## [1.1.0] - 2017-03-29
### Added
- Slack notifications are sent when someone gives Kudo's
- Slack notifications are sent when a goal is reached

### Changed
- Minor bug fixes

## [1.0.2] - 2017-03-02
### Added
- Feed with last transactions

## [1.0.1] - 2017-01-26
### Changed
- Bug fix previous goal

