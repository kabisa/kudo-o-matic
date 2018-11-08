# frozen_string_literal: true

module QueryTypes
  GoalQueryType = GraphQL::ObjectType.define do
    name "GoalQueryType"
    description "The goal query type"

    # find all records
    field :goals, types[Types::GoalType], function: Functions::FindAll.new(Goal)

    field :goalById, Types::GoalType, function: Functions::FindById.new(Goal)
  end
end
