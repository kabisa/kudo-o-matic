# frozen_string_literal: true

module Mutations
  TeamMutation = GraphQL::ObjectType.define do
    name "TeamMutation"
    description "All team related mutations"

    field :createTeam, Types::TeamType do
      description "Create a new team"
      argument :name, types.String

      # define return type
      type Types::TeamType

      resolve ->(_obj, args, ctx) do
        current_user = ctx[:current_user]
        if current_user.blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end

        team = Team.new(name: args[:name])

        if team.save
          team.add_member(current_user, 'admin')

          return team
        else
          raise GraphQL::ExecutionError, team.errors.full_messages.join(', ')
        end
      end
    end
  end
end
