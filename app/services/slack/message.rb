module Slack::Message
  def send_goal_announcement(goal, new_goal)
    client = Slack::Web::Client.new(token: goal.kudos_meter.team.slack_bot_access_token)

    current_goal_message = ":tada: We've just reached goal '#{goal.name}' at #{goal.amount} Kudos :tada:"
    blocks = [create_markdown_block(current_goal_message)]

    next_goal_message = "Our next goal is '#{new_goal.name}' at #{new_goal.amount} Kudos, " +
        "so keep the Kudos coming and we'll be there in no time! :muscle:"

    blocks << create_markdown_block(next_goal_message)

    client.chat_postMessage(channel: goal.kudos_meter.team.channel_id, blocks: blocks)
  end

  def send_post_announcement(post)
    client = Slack::Web::Client.new(token: post.team.slack_bot_access_token)

    sender_string = post.sender.slack_id == nil ? "#{post.sender.name}" : "<@#{post.sender.slack_id}>"

    message = "#{sender_string} just gave #{post.amount} kudos to #{get_post_receivers(post)} for #{post.message}"
    blocks = [create_markdown_block(message)]
    blocks << create_post_subscript(post.id)

    client.chat_postMessage(channel: post.team.channel_id, blocks: blocks)
  end

  def list_guidelines(slack_team_id)
    team = Team.find_by_slack_team_id(slack_team_id)

    raise InvalidCommand.new('No team with that Slack ID') if team.nil?

    guidelines = Guideline.where(:team => team).order(:kudos)

    if guidelines.none?
      return [create_markdown_block("No guidelines")]
    else
      return [create_markdown_block(guidelines_to_list(guidelines))]
    end
  end

  private

  def send_ephemeral_message(team, channel, user, message)
    client = Slack::Web::Client.new(token: team.slack_bot_access_token)

    client.chat_postEphemeral(channel: channel, user: user, text: message)
  end

  def create_message(slack_client, slack_message)
    message = "saying: '#{slack_message['text']}'"
    mentioned_users = message.scan(/(?=<).*?(?<=>)/)

    mentioned_users.each do |mentioned_user|
      user_info = slack_client.users_info(user: mentioned_user.tr('<>@', ''))
      message[mentioned_user] = user_info['user']['name']
    end

    message
  end

  def update_message_to_post(channel_id, message, post)
    user = User.find_by_slack_id(message[:user])
    client = Slack::Web::Client.new(token: user.slack_access_token)

    blocks = [create_markdown_block(message[:text])]
    blocks << create_post_subscript(post.id)

    client.chat_update(channel: channel_id, ts: message[:ts], blocks: blocks)
  end

  def send_welcome_message(team)
    client = Slack::Web::Client.new(token: team.slack_bot_access_token)

    client.chat_postMessage(channel: team.channel_id, text: "Is it a bird? is it a plane? It's Kudo-O-Matic!")
  end

  def create_markdown_block(text)
    {
        type: "section",
        text: {
            type: "mrkdwn",
            text: text
        }
    }
  end

  def message_is_kudo_o_matic_post?(message)
    last_block = message['blocks'].last

    Post.exists?(id: last_block['block_id'])
  end

  def create_post_subscript(post_id)
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