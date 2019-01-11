module Mutations
  class CreateTeamMutation < BaseMutation
    null true

    argument :name, String, required: true, description: 'The name of the team to create'

    field :team, Types::TeamType, null: true
    field :errors, [String], null: false

    def resolve(name:)
      team = Team.new(name: name)

      if team.save
        team.add_member(context[:current_user], 'admin')
        { team: team, errors: [] }
      else
        { team: nil, errors: team.errors.full_messages }
      end
    end
  end
end