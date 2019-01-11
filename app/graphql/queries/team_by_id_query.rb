module Queries
  class TeamByIdQuery < BaseQuery
    type Types::TeamType, null: true
    description "Query a team by id"

    argument :id, ID, required: true

    def resolve(id:)
      Team.find(id)
    end
  end
end