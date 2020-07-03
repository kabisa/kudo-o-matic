module Slack::Support
  private

  def find_team(slack_team_id)
    team = Team.where(:slack_team_id => slack_team_id).take

    if team == nil
      raise Slack::Exceptions::InvalidCommand.new('This workspace does not have an associated Kudo-o-matic team, contact an admin')
    end

    team
  end

  def find_user(slack_user_id)
    user = User.where(:slack_id => slack_user_id).take

    if user == nil
      raise Slack::Exceptions::InvalidCommand.new('No Kudo-o-matic user found with that Slack ID')
    end

    user
  end

end