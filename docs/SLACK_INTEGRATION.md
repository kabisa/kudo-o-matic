
# Slack integration  
## Table of contents 
- [Features](#features)
- [General information](#general-information)
	- [Add Slack app to workspace](#add-to-workspace)
	- [Connecting Kudo-o-matic accounts to Slack](#register-accounts)
- [Developing](#development)
	- [Creating a Slack app](#create-app)
	- [Configuring the app](#configure-app)
	    - [Redirect url's](#redirect-url)
	    - [App Settings](#app-settings)
    	    - [Incoming webhooks](#incoming-webhooks)
    	    - [Slash commands](#slash-commands)
    	    - [OAuth and Permissions](#oauth)
    	    - [Event subscription](#event-subscription)
    	    - [User ID Translation](#id-translation)
    	- [Setting env variables](#env-variables)

<a  name="features"></a>
## Features
Kudo-O-Matic has the following Slack features:  
- Create posts via Slack  
- Send a message to a specific slack channel to announce new posts  
- Send a message to a specific slack channel to announce the achievements of goals
- Like a Kudo-O-Matic post by adding the Kudos emoji to a post announcement message
- Create a Kudo-O-Matic post by adding a Kudos emoji to a random Slack message

<a  name="general-information"></a>
## General information
<a  name="add-to-workspace"></a>
### Add Slack app to workspace
Team admins can add the Slack app via the 'add to slack' button on the integration section found on the team management page.  
This is done via the [Slack OAuth v2 flow](https://api.slack.com/authentication/oauth-v2). The team id is passed to the backend via the state parameter. The flow is as followed:

1. Team admin clicks the 'add to slack' button
2. Make a request to the slack auth endpoint
3. Admin can select a channel to post messages to and accept
4. Redirect to the backend and use the temp token, client id and client secret to retrieve an access token and workspace information
5. Store the access token, channel id and slack team id

The workspace is now configured to use Kudo-O-Matic features.

<a  name="register-accounts"></a>
### Connecting Kudo-O-Matic accounts to Slack
In order to create posts and make announcement there needs to be a connection between Slack accounts and Kudo-O-Matic accounts. This is done via the same OAuth flow as described above but only providing user-scopes.

1. User visit their Kudo-O-Matic profile page and press the 'Connect to Slack' button
2. This will trigger the OAuth flow
3. The access token and Slack ID will be stored for the user

<a  name="development"></a>
## Development
### The Kabisa Slack apps
The Slack apps are managed by managed services using their kabisasupport Slack user. If you need to change scopes, permissions or other settings you need to refer to them.

You can find the Slack apps that you manage [here](https://api.slack.com/apps).

<a  name="create-app"></a>
### Creating a slack app
Before starting development on Slack features we recommend you read through the [basics first](https://api.slack.com/start/overview). This will give you a basic idea about how Slack apps work and what they are capable of.

For local development it's recommended you [create a slack app](https://api.slack.com/apps?new_app=1) yourself so you don't have to bother Managed Services constantly when you want to change settings or re-add the app to the workspace. In order to facilitate a Slack app you must also [create a workspace](https://slack.com/create#email).

Now that you have your very own Slack app you'll need to configure it with the correct settings in order to use it with the existing Kudo-O-Matic application.

<a  name="configure-app"></a>
### Configuring the Slack app
The slack app will need certain permissions and features enabled otherwise it won't work. Some settings may be dependant on your local work environment like OAuth redirect url's. 
<a  name="redirect-url"></a>
#### redirect URL's
In order to get redirects to your local machine we recommend using [ngrok](https://ngrok.com/download). Follow the steps for downloading and creating an account. After you've done that use the following command to start the service:

    ngrok http 3000

It should provide you an output similar to the following:

    Forwarding        http://000a4d61.ngrok.io -> http://localhost:3000
    Forwarding        https://000a4d61.ngrok.io -> http://localhost:3000

Note the `http://000a4d61.ngrok.io` this will be the base url.

<a  name="app-settings"></a>
#### App Settings
<a  name="incoming-webhooks"></a>
#### Incoming webhooks
Turn this feature on.

<a  name="slash-commands"></a>
#### Slash commands
Create the following commands and make sure you check this option for each command:
> Escape channels, users, and links sent to your app

1 . Kudo
	- command: `/kudo`
	- url: `<your-base-url>/slack/kudo`

2 . guidlines
	- command: `/guidlines`
	- url: `<your-base-url>/slack/guidelines`

<a  name="oauth"></a>
#### OAuth & Permissions
Add the following redirect url:

    <your-base-url>
The following bot token scopes need to be added:
- channels:history
- channels:join
- channels:read
- chat:write
- chat:write.public
- commands
- incoming-webhook
- reactions:read
- users:read

The following User Token Scopes need to be added:
- chat:write

<a name="event-subscription"></a>
#### Event subscription
Make sure the app is running when editing these settings because Slack will [send a challenge request](https://api.slack.com/events/url_verification) to make sure your app is ready to receive events.

Request URL:

`<your-base-url>/slack/event`

Subscribe to bot events:
- reaction_added
- reaction_removed

<a  name="id-translation"></a>
#### User ID Translation
Turn this feature on.

<a  name="env-variables"></a>
### Setting env variables
set the following two environment variables:

    SLACK_CLIENT_ID: <your-client-id>
    SLACK_CLIENT_SECRET: <your-client-secret>
    ROOT_URL: <your-base-url> without 'http(s)://'!

	

