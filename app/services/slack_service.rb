module SlackService
  class InvalidRequest < RuntimeError;
  end
  class InvalidCommand < RuntimeError;
  end

  public

  def create_post(command_text, team_id, user_id)
    slack_users = command_text.scan(/(?=<).*?(?<=>)/)

    receivers = []

    slack_users.each do |slack_user|
      id = slack_user[slack_user.index('@') + 1..slack_user.index('|') - 1]
      user = User.where(slack_id: id).take

      if user == nil
        name = slack_user[slack_user.index('|') + 1..slack_user.index('>') - 1]
        raise InvalidCommand.new "#{name} has not connected their account to Slack."
      end

      receivers << user
    end

    if receivers.length == 0
      raise InvalidCommand.new "Did you forget to mention any users with the '@' symbol?"
    end

    message = command_text[/'(.*?)'/m, 1]

    if message == nil || message == ""
      raise InvalidCommand.new 'Did you include a message surrounded by \'?'
    end

    amount = command_text.split(' ').last

    if amount == nil || amount == ""
      raise InvalidCommand.new 'Did you include an amount?'
    end

    begin
      Integer(amount)
    rescue ArgumentError
      raise InvalidCommand.new 'Did you include an amount?'
    end

    team = Team.where(:slack_team_id => team_id).take

    if team == nil
      raise InvalidCommand.new 'This workspace does not have an associated Kudo-o-matic team, contact an admin'
    end

    sender = User.where(:slack_id => user_id).take

    if sender == nil
      raise InvalidCommand.new 'Your Slack account is not linked to Kudo-o-matic, use the /register command'
    end

    Post.new(
        message: message,
        amount: amount,
        sender: sender,
        receivers: receivers,
        team: team,
        kudos_meter: team.active_kudos_meter
    )
  end

  def send_post_announcement(post)
    receiver_string = ""
    post.receivers.each_with_index do |receiver, index|
      receiver_string += receiver.slack_id == nil ? "#{receiver.name}" : "<@#{receiver.slack_id}>"

      if post.receivers.count > 1 && index != post.receivers.count - 1
        receiver_string += (index == (post.receivers.count - 2)) ? ' and ' : ', '
      end
    end

    sender_string = post.sender.slack_id == nil ? "#{post.sender.name}" : "<@#{post.sender.slack_id}>"

    payload = {
        token: post.team.slack_bot_access_token,
        text: "#{sender_string} just gave #{post.amount} kudos to #{receiver_string} for #{post.message}",
        channel: post.team.channel_id,
    }

    RestClient.post Settings.slack_post_message_endpoint, payload
  end

  def connect_account(command_text, user_id)
    slack_register_token = command_text

    raise InvalidCommand.new 'please provide a register token' unless slack_register_token != ''

    raise InvalidCommand.new 'This slack account is already linked to kudo-o-matic' unless User.where(:slack_id => user_id).count == 0

    user = User.where(:slack_registration_token => slack_register_token).take

    raise InvalidCommand.new 'Invalid registration token' unless user != nil

    raise InvalidCommand.new 'This kudo-o-matic account is already linked to Slack.' unless user.slack_id == nil

    user.slack_id = user_id
    user.slack_registration_token = nil
    raise InvalidCommand.new "That didn't quite work, #{user.errors.full_messages.join(', ')}" unless user.save
  end

  def add_to_workspace(code, team_id)
    if code == nil
      raise InvalidRequest.new 'Auth token is missing'
    end

    if team_id == nil
      raise InvalidRequest.new 'Team id is missing'
    end
    team = Team.find(team_id)

    payload = {
        code: code,
        client_id: ENV['SLACK_CLIENT_ID'],
        client_secret: ENV['SLACK_CLIENT_SECRET']
    }

    response = RestClient.post Settings.slack_acccess_token_endpoint, payload
    parsed_result = ActiveSupport::JSON.decode(response.body)

    puts parsed_result

    team.channel_id = parsed_result['incoming_webhook']['channel_id']
    team.slack_bot_access_token = parsed_result["access_token"]
    team.slack_team_id = parsed_result["team"]["id"]

    raise InvalidRequest.new "That didn't quite work, #{team.errors.full_messages.join(', ')}" unless team.save

    send_welcome_message(team)
  end

  def list_guidelines(slack_team_id)
    team = Team.find_by_slack_team_id(slack_team_id)

    raise InvalidCommand.new 'No team with that Slack ID' unless team != nil

    guidelines = Guideline.where(:team => team).order(:kudos)

    if guidelines.count == 0
      return [{
                  type: "section",
                  text: {
                      type: "mrkdwn",
                      text: "No guidelines"
                  }
              }]
    end

    text = ""

    guidelines.each do |guideline|
      text += "• #{guideline.name} *#{guideline.kudos}* \n"
    end

    [{
         type: "section",
         text: {
             type: "mrkdwn",
             text: text
         }
     }]
  end

  private

  def send_welcome_message(team)
    payload = {
        token: team.slack_bot_access_token,
        text: "Is it a bird? is it a plane? It's kudo-o-matic!",
        channel: team.channel_id
    }

    RestClient.post Settings.slack_post_message_endpoint, payload
  end

end