# frozen_string_literal: true


module Types
  TeamType = GraphQL::ObjectType.define do
    name "Team"

    field :id, !types.ID, "The Team ID"
    field :name, !types.String, "The Team Name"
    field :slug, !types.String, "The team slug (friendly id)"

    field :memberships, !types[Types::UserType] do
      description "The users that are member of the team"
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(User).load_many(obj.memberships.ids) }
    end
  end
end
