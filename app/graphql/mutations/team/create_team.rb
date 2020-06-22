module Mutations
  class Team::CreateTeam < BaseMutation
    null true

    argument :name, String, required: true, description: 'The name of the team to create'

    field :team, Types::TeamType, null: true

    def resolve(name:)
      team = ::Team.new(name: name)

      if team.save
        team.add_member(context[:current_user], 'admin')
        { team: team }
      else
        return Util::ErrorBuilder.build_errors(context, team.errors)
      end
    end
  end
end