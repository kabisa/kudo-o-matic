class SlackService
  class InvalidRequest < RuntimeError; end

  class InvalidCommand < RuntimeError; end

  public

  def self.create_post(command_text, slack_team_id, slack_user_id)
    team = find_team(slack_team_id)
    sender = find_sender(slack_user_id)
    receivers = get_receivers_from_command(command_text)
    message = parse_message(command_text)
    amount = parse_amount(command_text)

    begin
      PostCreator.create_post(message, amount, sender, receivers, team)
    rescue PostCreator::PostCreateError => e
      raise InvalidCommand.new(e)
    end
  end

  def self.send_post_announcement(post)
    client = Slack::Web::Client.new(token: post.team.slack_bot_access_token)

    sender_string = post.sender.slack_id == nil ? "#{post.sender.name}" : "<@#{post.sender.slack_id}>"

    message = "#{sender_string} just gave #{post.amount} kudos to #{get_post_receivers(post)} for #{post.message}"
    blocks = create_markdown_block(message)
    blocks << create_post_subscript(post.id)

    client.chat_postMessage(channel: post.team.channel_id, blocks: blocks)
  end

  def self.connect_account(code, user_id)
    client = Slack::Web::Client.new
    if code == nil
      raise InvalidRequest.new('Auth token is missing')
    end

    auth_result = client.oauth_v2_access(
        code: code,
        client_id: ENV['SLACK_CLIENT_ID'],
        client_secret: ENV['SLACK_CLIENT_SECRET'],
        redirect_uri: generate_user_redirect_uri(user_id)
    )

    user = User.find(user_id)
    user.slack_access_token = auth_result[:authed_user][:access_token]
    user.slack_id = auth_result[:authed_user][:id]

    raise InvalidCommand.new("That didn't quite work, #{user.errors.full_messages.join(', ')}") unless user.save
  end

  def self.add_to_workspace(code, team_id)
    client = Slack::Web::Client.new
    if code == nil
      raise InvalidRequest.new('Auth token is missing')
    end

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

    raise InvalidRequest.new("That didn't quite work, #{team.errors.full_messages.join(', ')}") unless team.save

    join_all_channels(team)
    send_welcome_message(team)
  end

  def self.list_guidelines(slack_team_id)
    team = Team.find_by_slack_team_id(slack_team_id)

    raise InvalidCommand.new('No team with that Slack ID') if team.nil?

    guidelines = Guideline.where(:team => team).order(:kudos)

    if guidelines.none?
      return create_markdown_block("No guidelines")
    else
      return create_markdown_block(guidelines_to_list(guidelines))
    end
  end

  def self.get_team_oauth_url(team_id)
    base_uri = generate_base_oauth_url

    query = {
        redirect_uri: generate_team_redirect_uri(team_id),
        client_id: ENV['SLACK_CLIENT_ID'],
        scope: Settings.slack_scopes,
    }

    base_uri.query = query.to_query

    base_uri
  end

  def self.get_user_oauth_url(user_id)
    base_uri = generate_base_oauth_url

    query = {
        redirect_uri: generate_user_redirect_uri(user_id),
        client_id: ENV['SLACK_CLIENT_ID'],
        user_scope: Settings.slack_user_scopes,
    }

    base_uri.query = query.to_query

    base_uri
  end

  def self.reaction_added(team_id, event)
    return unless supported_emoji?(event)

    team = Team.find_by_slack_team_id(team_id)
    user = User.find_by_slack_id(event[:user])
    message = get_message_from_event(team_id, event)

    if message_is_kudo_o_matic_post?(message)
      like_post(user, message)
    else
      post = create_post_from_message(team, user, message)
      update_message_to_post(event[:item][:channel], message, post)
    end
  end

  def self.reaction_removed(team_id, event)
    return unless supported_emoji?(event)

    user = User.find_by_slack_id(event[:user])
    message = get_message_from_event(team_id, event)

    if message_is_kudo_o_matic_post?(message)
      unlike_post(user, message)
    end
  end

  private


  def self.join_all_channels(team)
    client = Slack::Web::Client.new(token: team.slack_bot_access_token)

    channel_response = client.conversations_list(types: 'public_channel', exclude_archived: true)

    channel_response[:channels].each do |channel|
      client.conversations_join(channel: channel[:id])
    end
  end

  def self.supported_emoji?(event)
    emojis = Settings.slack_accepted_emojis.split(',')

    emojis.include?(event[:reaction])
  end

  def self.like_post(user, message)
    post = Post.find(message[:blocks].last[:block_id])

    post.liked_by(user) unless user.voted_up_on? post
  end

  def self.unlike_post(user, message)
    post = Post.find(message[:blocks].last[:block_id])

    post.unliked_by(user) if user.voted_up_on? post
  end

  def self.get_message_from_event(team_id, event)
    team = Team.find_by_slack_team_id(team_id)
    client = Slack::Web::Client.new(token: team.slack_bot_access_token)
    message_response = client.conversations_history(channel: event[:item][:channel], latest: event[:item][:ts], limit: 1, inclusive: true)

    message_response[:messages][0]
  end

  def self.create_post_from_message(team, user, slack_message)
    receiver = User.find_by_slack_id(slack_message[:user])

    raise InvalidRequest.new("That user has not connected their account to Slack.") if receiver == nil

    message = "saying: '#{slack_message[:text]}'"

    begin
      PostCreator.create_post(message, 1, user, [receiver], team)
    rescue PostCreator::PostCreateError => e
      raise InvalidCommand.new(e)
    end
  end

  def self.update_message_to_post(channel_id, message, post)
    user = User.find_by_slack_id(message[:user])
    client = Slack::Web::Client.new(token: user.slack_access_token)

    new_message = create_markdown_block(message[:text])
    new_message << create_post_subscript(post.id)

    client.chat_update(channel: channel_id, ts: message[:ts], blocks: new_message)
  end

  def self.generate_base_oauth_url
    URI::HTTP.build(
        host: Settings.slack_auth_endpoint,
        path: '/oauth/v2/authorize',
        query: {
            client_id: ENV['SLACK_CLIENT_ID'],
        }.to_query
    )
  end

  def self.generate_team_redirect_uri(team_id)
    URI::HTTP.build(host: ENV['ROOT_URL'], path: "/auth/callback/slack/team/#{team_id}")
  end

  def self.generate_user_redirect_uri(user_id)
    URI::HTTP.build(host: ENV['ROOT_URL'], path: "/auth/callback/slack/user/#{user_id}")
  end

  def self.send_welcome_message(team)
    client = Slack::Web::Client.new(token: team.slack_bot_access_token)

    client.chat_postMessage(channel: team.channel_id, text: "Is it a bird? is it a plane? It's Kudo-O-Matic!")
  end

  def self.get_post_receivers(post)
    receiver_string = ""
    post.receivers.each_with_index do |receiver, index|
      receiver_string += receiver.slack_id == nil ? "#{receiver.name}" : "<@#{receiver.slack_id}>"

      if post.receivers.count > 1 && index != post.receivers.count - 1
        receiver_string += (index == (post.receivers.count - 2)) ? ' and ' : ', '
      end
    end

    receiver_string
  end

  def self.get_receivers_from_command(text)
    slack_users = text.scan(/(?=<).*?(?<=>)/)

    receivers = []

    slack_users.each do |slack_user|
      id = slack_user[slack_user.index('@') + 1..slack_user.index('|') - 1]
      user = User.where(slack_id: id).take

      if user == nil
        name = slack_user[slack_user.index('|') + 1..slack_user.index('>') - 1]
        raise InvalidCommand.new("#{name} has not connected their account to Slack.")
      end

      receivers << user
    end

    if receivers.length == 0
      raise InvalidCommand.new("Did you forget to mention any users with the '@' symbol?")
    end

    receivers
  end

  def self.parse_amount(text)
    amount = text.split(' ').last

    if amount.empty?
      raise InvalidCommand.new('Did you include an amount?')
    end

    begin
      Integer(amount)
    rescue ArgumentError
      raise InvalidCommand.new('Did you include an amount?')
    end

    amount
  end

  def self.guidelines_to_list(guidelines)
    text = ""

    guidelines.each do |guideline|
      text += "• #{guideline.name} *#{guideline.kudos}* \n"
    end

    text
  end

  def self.find_team(slack_team_id)
    team = Team.where(:slack_team_id => slack_team_id).take

    if team == nil
      raise InvalidCommand.new('This workspace does not have an associated Kudo-o-matic team, contact an admin')
    end

    team
  end

  def self.find_sender(slack_user_id)
    sender = User.where(:slack_id => slack_user_id).take

    if sender == nil
      raise InvalidCommand.new('Your Slack account is not linked to Kudo-o-matic, use the /register command')
    end

    sender
  end

  def self.parse_message(command_text)
    message = command_text[/'(.*?)'/m, 1]

    if message.empty?
      raise InvalidCommand.new('Did you include a message surrounded by \'?')
    end

    message
  end

  def self.create_markdown_block(text)
    [{
         type: "section",
         text: {
             type: "mrkdwn",
             text: text
         }
     }]
  end

  def self.message_is_kudo_o_matic_post?(message)
    last_block = message[:blocks].last

    Post.exists?(id: last_block[:block_id])
  end

  def self.create_post_subscript(post_id)
    {
        type: 'context',
        block_id: post_id.to_s,
        elements: [
            type: 'mrkdwn',
            text: '_This message is a Kudo-O-Matic post_'
        ]
    }
  end
end