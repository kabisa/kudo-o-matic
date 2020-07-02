module Slack::Support
  private

  def get_message_from_event(team_id, event)
    team = Team.find_by_slack_team_id(team_id)
    client = Slack::Web::Client.new(token: team.slack_bot_access_token)
    message_response = client.conversations_history(channel: event['item']['channel'], latest: event['item']['ts'], limit: 1, inclusive: true)

    message_response['messages'][0]
  end

  def get_post_receivers(post)
    receiver_string = ""
    post.receivers.each_with_index do |receiver, index|
      receiver_string += receiver.slack_id == nil ? "#{receiver.name}" : "<@#{receiver.slack_id}>"

      if post.receivers.count > 1 && index != post.receivers.count - 1
        receiver_string += (index == (post.receivers.count - 2)) ? ' and ' : ', '
      end
    end

    receiver_string
  end

  def get_receivers_from_command(text)
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

  def parse_amount(text)
    amount = text.split(">").last.split("for").first

    if amount.blank?
      raise InvalidCommand.new('Did you include an amount?')
    end

    begin
      Integer(amount)
    rescue ArgumentError
      raise InvalidCommand.new('Did you include an amount?')
    end

    amount
  end

  def parse_message(command_text)
    message = command_text[/(?<=for).*$/]
    message.strip!

    if message.blank?
      raise InvalidCommand.new('Did you include a message?')
    end

    message
  end

  def guidelines_to_list(guidelines)
    text = ""

    guidelines.each do |guideline|
      text += "• #{guideline.name} *#{guideline.kudos}* \n"
    end

    text
  end

  def find_team(slack_team_id)
    team = Team.where(:slack_team_id => slack_team_id).take

    if team == nil
      raise InvalidCommand.new('This workspace does not have an associated Kudo-o-matic team, contact an admin')
    end

    team
  end

  def find_sender(slack_user_id)
    sender = User.where(:slack_id => slack_user_id).take

    if sender == nil
      raise InvalidCommand.new('Your Slack account is not linked to Kudo-o-matic, use the /register command')
    end

    sender
  end
end