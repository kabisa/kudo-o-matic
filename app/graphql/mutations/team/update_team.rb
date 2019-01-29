module Mutations
  class Team::UpdateTeam < BaseMutation
    null true

    argument :name, String, required: true, description: 'The updated name of the team'
    argument :team_id, ID, required: true, description: 'The ID of the team to update'

    field :team, Types::TeamType, null: true
    field :errors, [String], null: false

    def resolve(name:, team_id:)
      team = ::Team.find(team_id)

      if team.update(name: name)
        { team: team, errors: [] }
      else
        { team: nil, errors: team.errors.full_messages }
      end
    end
  end
end