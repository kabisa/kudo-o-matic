module Slack::Auth
  def connect_account(code, user_id)
    client = Slack::Web::Client.new

    raise Slack::Exceptions::InvalidCommand.new('Missing auth token') if code.nil?
    raise Slack::Exceptions::InvalidCommand.new('Missing user id') if user_id.nil?

    auth_result = client.oauth_v2_access(
        code: code,
        client_id: ENV['SLACK_CLIENT_ID'],
        client_secret: ENV['SLACK_CLIENT_SECRET'],
        redirect_uri: generate_user_redirect_uri(user_id)
    )

    user = User.find(user_id)

    raise Slack::Exceptions::InvalidCommand.new('This Kudo-O-Matic account is already linked to Slack') unless user.slack_id.nil?

    raise Slack::Exceptions::InvalidCommand.new('This Slack account is already linked to Kudo-O-Matic') if User.exists?(slack_id: auth_result['authed_user']['id'])

    user.slack_access_token = auth_result['authed_user']['access_token']
    user.slack_id = auth_result['authed_user']['id']

    raise Slack::Exceptions::InvalidCommand.new("That didn't quite work, #{user.errors.full_messages.join(', ')}") unless user.save
  end

  def add_to_workspace(code, team_id)
    client = Slack::Web::Client.new

    raise Slack::Exceptions::InvalidRequest.new('Auth token is missing') if code.nil?

    raise Slack::Exceptions::InvalidRequest.new('Team id is missing') if team_id.nil?

    auth_result = client.oauth_v2_access(
        code: code,
        client_id: ENV['SLACK_CLIENT_ID'],
        client_secret: ENV['SLACK_CLIENT_SECRET'],
        redirect_uri: generate_team_redirect_uri(team_id)
    )

    team = Team.find(team_id)
    team.channel_id = auth_result['incoming_webhook']['channel_id']
    team.slack_bot_access_token = auth_result["access_token"]
    team.slack_team_id = auth_result["team"]["id"]

    raise Slack::Exceptions::InvalidRequest.new("That didn't quite work, #{team.errors.full_messages.join(', ')}") unless team.save

    join_all_channels(team) if Settings.slack_join_all_channels
    send_welcome_message(team)
  end

  def get_team_oauth_url(team_id)
    base_uri = generate_base_oauth_url

    query = {
        redirect_uri: generate_team_redirect_uri(team_id),
        client_id: ENV['SLACK_CLIENT_ID'],
        scope: Settings.slack_scopes,
    }

    base_uri.query = query.to_query

    base_uri.to_s
  end

  def get_user_oauth_url(user_id)
    base_uri = generate_base_oauth_url

    query = {
        redirect_uri: generate_user_redirect_uri(user_id),
        client_id: ENV['SLACK_CLIENT_ID'],
        user_scope: Settings.slack_user_scopes,
    }

    base_uri.query = query.to_query

    base_uri.to_s
  end

  private

  def generate_base_oauth_url
    URI::HTTPS.build(
        host: Settings.slack_auth_endpoint,
        path: '/oauth/v2/authorize',
        query: {
            client_id: ENV['SLACK_CLIENT_ID'],
        }.to_query
    )
  end

  def generate_team_redirect_uri(team_id)
    URI::HTTPS.build(host: ENV['ROOT_URL'], path: "/auth/callback/slack/team/#{team_id}")
  end

  def generate_user_redirect_uri(user_id)
    URI::HTTPS.build(host: ENV['ROOT_URL'], path: "/auth/callback/slack/user/#{user_id}")
  end

  def join_all_channels(team)
    client = Slack::Web::Client.new(token: team.slack_bot_access_token)

    channel_response = client.conversations_list(types: 'public_channel', exclude_archived: true)

    channel_response[:channels].each do |channel|
      client.conversations_join(channel: channel[:id])
    end
  end

end