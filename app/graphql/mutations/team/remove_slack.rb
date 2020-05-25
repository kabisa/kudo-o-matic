module Mutations
  class Team::RemoveSlack < BaseMutation
    null true

    argument :team_id, ID, required: true, description: 'The ID of the team to update'

    field :team, Types::TeamType, null: true

    def resolve(team_id:)
      team = ::Team.find(team_id)

      team.slack_team_id = nil
      team.slack_bot_access_token = nil
      team.channel_id = nil

      if team.save
        {team: team}
      else
        return Util::ErrorBuilder.build_errors(context, team.errors)
      end
    end
  end
end