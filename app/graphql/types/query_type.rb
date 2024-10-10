# frozen_string_literal: true

module Types
  class QueryType < BaseObject
    field :team_by_id, resolver: Queries::TeamByIdQuery

    field :viewer, resolver: Queries::ViewerQuery
  end
end
