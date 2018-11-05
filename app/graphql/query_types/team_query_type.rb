# frozen_string_literal: true

module QueryTypes
  TeamQueryType = GraphQL::ObjectType.define do
    name "TeamQueryType"
    description "The team query type"

    # find all records
    field :teams, types[Types::TeamType], function: Functions::FindAll.new(Team) do
      argument :orderBy, types.String, "Column to order the results by", as: :order
    end

    # find team by id
    field :teamById, Types::TeamType, function: Functions::FindById.new(Team)
  end
end
