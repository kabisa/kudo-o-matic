# Migrating from Linode to Heroku

In order to migrate from Linode to Heroku certain steps need te be performed by either Managed Services (MS) or a Kudo developer (developer).


## 1. Create a new Heroku App
### Who
MS
### Description
A new Heroku app needs to be created by Managed Services. Afterwards the kudo developer can be added as an admin so he can perform actions like changing environment variables.

The app will need the following buildpack:
- heroku/ruby buildpack

The app will need the following dynos:
- web bundle exec puma -C config/puma.rb
- workerbundle exec sidekiq -c 3 -q default -q mailers

The app will need the following add-ons:
- Heroku Postgres add-on
- Heroku Redis add-on


## 2. Copy environment variables
### Who
MS, developer
### Description
MS needs to log into the production Linode server and copy all the environment variables.
Then these environment variables need to be send to the developer via Keybase so he can import them into Heroku.

## 3. Create GitHub Action
### Who 
developer
### Description
Create a new GitHub Action that deploys the application to Heroku when there is a push to master. Deploying to staging is already done this way and this can used as an example.

## 4. Copy DB from Linode to Heroku
### Who 
MS, developer
### Description
Following the steps described by [Heroku](https://devcenter.heroku.com/articles/heroku-postgres-import-export#import) a database export needs to be made using `pg_dump` from the Linode database.

This database needs to be uploaded to a publicly available url. Heroku recommends using aws s3.

Then this URL can be shared with the developer so he can import it into Heroku.

## 5. Update DNS
### Who
MS
### Description
The DNS records need to be updated so 'kudos.backend.kabisa.io' points towards Heroku and not Linode.
This can be done using [the steps](https://devcenter.heroku.com/articles/custom-domains) described by Heroku.

This also needs to be done for the staging environment 'kudo-o-matic-staging.herokuapp.com'. The staging Heroku app already exists and can be found [here](https://dashboard.heroku.com/apps/kudo-o-matic-staging/settings)

## 6. Update Slack app
### Who
MS, developer
### Description
The settings for the Kudo-O-Matic Slack app need to be updated. The best way to do this is via screen sharing. 
The developer will provide a list of changes/settings that MS needs to set.

## 7. Deploy Kudo-frontend
### Who
developer
### Description
The front end needs to be deployed by opening a PR to master and accepting it.
> Remember to set the new `REACT_APP_API_BASE_URL` env variable in Netlify

## 8. Run remove duplicate virtual users rake task.
### Who
Developer
### Description
Run the `remove_duplicate_virtual_users` rake task in order to clean up the database.

Run using `bundle exec rake remove_duplicate_virtual_users:remove`

## 9. Delete Jenkins pipelines
### Who
MS
### Description
Since deployment is now done via GitHub Action the Jenkins pipelines can be removed.

## 10. Update Procfile
### Who
Developer
### description
The Procfile needs to be updated with:

`release: bundle exec rake db:migrate`

In order to run database migrations on each release.
See the [Heroku docs](https://devcenter.heroku.com/articles/release-phase) for more information.


## 11. Remove Dokku configuration files
### Who
Developer
### Description
Remove the Dokku configuration file (`app.json`) to clean up the project.

## 13. Add Kudo-O-Matic to Slack
### Who
MS
### Description
In order to activate the new Slack integration the app must be added to Slack.
Someone with both Slack admin rights and Kudo-O-Matic admin rights needs to do this.

Steps:
- Sign into Kudo-O-Matic
- In the top right go to the dropdown > `Manage team`
- Select the `Integrations` section
- Click the 'Add to Slack' button
- Select the `General` channel as the place to post kudos. (the dropdown)

You should receive a Slack message to confirm everything is working. 


