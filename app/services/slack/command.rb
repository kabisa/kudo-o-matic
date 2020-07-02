module Slack::Command
  def create_post(command_text, slack_team_id, slack_user_id)
    team = find_team(slack_team_id)
    sender = find_user(slack_user_id)
    receivers = get_receivers_from_command(command_text)
    message = parse_message(command_text)
    amount = parse_amount(command_text)

    begin
      PostCreator.create_post(message, amount, sender, receivers, team)
    rescue PostCreator::PostCreateError => e
      raise Slack::SlackService::InvalidCommand.new(e)
    end
  end

  def list_guidelines(slack_team_id)
    team = find_team(slack_team_id)

    guidelines = Guideline.where(:team => team).order(:kudos)

    if guidelines.none?
      return [create_markdown_block("No guidelines")]
    else
      return [create_markdown_block(guidelines_to_list(guidelines))]
    end
  end

  private

  def parse_amount(text)
    amount = text.split(">").last.split("for").first

    if amount.blank?
      raise Slack::SlackService::InvalidCommand.new('Did you include an amount?')
    end

    begin
      Integer(amount)
    rescue ArgumentError
      raise Slack::SlackService::InvalidCommand.new('Did you include an amount?')
    end

    amount
  end

  def get_receivers_from_command(text)
    slack_users = text.scan(/(?=<).*?(?<=>)/)

    receivers = []

    slack_users.each do |slack_user|
      id = slack_user[slack_user.index('@') + 1..slack_user.index('|') - 1]
      user = User.where(slack_id: id).take

      if user == nil
        name = slack_user[slack_user.index('|') + 1..slack_user.index('>') - 1]
        raise Slack::SlackService::InvalidCommand.new("#{name} has not connected their account to Slack.")
      end

      receivers << user
    end

    if receivers.length == 0
      raise Slack::SlackService::InvalidCommand.new("Did you forget to mention any users with the '@' symbol?")
    end

    receivers
  end

  def parse_message(command_text)
    message = command_text[/(?<=for).*$/]
    message.strip!

    if message.blank?
      raise Slack::SlackService::InvalidCommand.new('Did you include a message?')
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

end