module Slack::Command
  def create_post(command_text, slack_team_id, slack_user_id)
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

end