
# Slack integration  
Kudo-o-matic has the following slack features:  
- Create post via Slack  
- Send message to a specific slack channel to announce new post  
  
* [General information](#general-information)
	* [Add Slack app to workspace](#add-to-workspace)
	* [Connecting Kudo-o-matic accounts to Slack](#register-accounts)
* [Developing](#development)
	* [Creating a Slack app](#create-app)
	* [Configuring the app](#configure-app)

<a  name="general-information"></a>
## General information
<a  name="add-to-workspace"></a>
### Add Slack app to workspace
Team admins can add the Slack app via the 'add to slack' button on the integration section found on the team page.  
This uses the [Slack OAuth v2 flow](https://api.slack.com/authentication/oauth-v2). The team id is passed to the backend via the state parameter. The flow is as followed:

1. Team admin clicks the 'add to slack' button
2. Make a request to the slack auth endpoint
3. Admin can select a channel to post messages to and accept
4. Redirect to the backend and use the temp token, client id and client secret to retrieve an access token and workspace information
5. Store the access token, channel id and slack team id

The workspace is now configured to use Kudo-o-matic features.

<a  name="register-accounts"></a>
### Connecting Kudo-o-matic accounts to Slack
In order to create posts and make announcement there needs to be a connection between Slack accounts and Kudo-o-matic accounts. This is done by generating a unique register token for each Kudo-o-matic user and executing a register command in Slack with the register token as parameter. The flow is as followed:

1. User copies the register command from the Kudo-o-matic profile page
2. User executes the command in a workspace that has the Kudo-o-matic Slack app installed
3. The backend fetches the user via the register token
4. The slack user id that was send with the request is stored for the corresponding user

<a  name="development"></a>
## Development
<a  name="create-app"></a>
### Creating a slack app
Before starting development on Slack features we recommend you read through the [basics first](https://api.slack.com/start/overview). This will give you a basic idea about how Slack apps work and what they are capable of.

For local development it's recommended you [create a slack app](https://api.slack.com/apps?new_app=1) yourself so you don't have to bother Managed Services constantly when you want to change settings or re-add the app to the workspace. In order to facilitate a Slack app you must also [create a workspace](https://slack.com/create#email).

Now that you have your very own Slack app you'll need to configure it with the correct settings in order to use it with the existing Kudo-o-matic application.

<a  name="configure-app"></a>
### Configuring the Slack app
The slack app will need certain permissions and features enabled otherwise it won't work. Some settings may be dependant on your local work environment like OAuth redirect url's. 

#### redirect URL's
In order to get redirects to your local machine we recommend using [ngrok](https://ngrok.com/download). Follow the steps for downloading and creating an account. After you've done that use the following command to start the service:

    ngrok http 3000

It should provide you an output similar to the following:

    Forwarding        http://000a4d61.ngrok.io -> http://localhost:3000
    Forwarding        https://000a4d61.ngrok.io -> http://localhost:3000

Note the `http://000a4d61.ngrok.io` this will be the base url.

#### Incoming webhooks
Turn this feature on.

#### Slash commands
Create the following commands.
For each command enable:
> Escape channels, users, and links sent to your app

 1. Register
	 - command: `/register`
	 - url: `<your-base-url>/slack/register`
2. Kudo
	- command: `/kudo`
	- url: `<your-base-url>/slack/kudo`

#### OAuth & Permissions
Add the following redirect url:

    <your-base-url>/auth/slack/callback
The following bot token scopes need to be added:
- chat:write
- chat:write.public
- commands
- incoming-webhook

The following User Token Scopes need to be added:
- reactions:read

#### User ID Translation
Turn this feature on.

#### Setting env variables
set the following two environment variables:

    SLACK_CLIENT_ID: <your-client-id>
    SLACK_CLIENT_SECRET: <your-client-secret>

	

