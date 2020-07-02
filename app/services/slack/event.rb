module Slack::Event
  def reaction_added(team_id, event)
    return unless supported_emoji?(event)

    team = Team.find_by_slack_team_id(team_id)
    user = User.find_by_slack_id(event['user'])
    message = get_message_from_event(team_id, event)

    if user.nil?
      send_ephemeral_message(team, event['item']['channel'], event['user'], "You're Slack account is not connected to Kudo-O-Matic")
      return
    end

    if message_is_kudo_o_matic_post?(message)
      like_post(user, message)
    else
      post = create_post_from_message(team, user, message)
      update_message_to_post(event['item']['channel'], message, post)
    end
  end

  def reaction_removed(team_id, event)
    return unless supported_emoji?(event)

    user = User.find_by_slack_id(event['user'])
    message = get_message_from_event(team_id, event)

    if message_is_kudo_o_matic_post?(message)
      unlike_post(user, message)
    end
  end

  private

  def supported_emoji?(event)
    emojis = Settings.slack_accepted_emojis.split(',')

    emojis.include?(event['reaction'])
  end

  def like_post(user, message)
    post = Post.find(message['blocks'].last['block_id'])

    post.liked_by(user) unless user.voted_up_on? post
  end

  def unlike_post(user, message)
    post = Post.find(message['blocks'].last['block_id'])

    post.unliked_by(user) if user.voted_up_on? post
  end

  def create_post_from_message(team, user, slack_message)
    client = Slack::Web::Client.new(token: team.slack_bot_access_token)
    receiver = User.find_by_slack_id(slack_message['user'])

    if receiver.nil?
      send_ephemeral_message(team, event['item']['channel'], event['user'], "The user you're giving kudos to has not connected their account to Slack.")
    end

    raise InvalidRequest.new("That user has not connected their account to Slack.") if receiver == nil

    message = create_message(client, slack_message)

    begin
      PostCreator.create_post(message, 1, user, [receiver], team, false)
    rescue PostCreator::PostCreateError => e
      raise InvalidCommand.new(e)
    end
  end
end