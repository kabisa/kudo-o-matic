# frozen_string_literal: true

module Types
  class QueryType < BaseObject
    guard ->(_obj, _args, ctx) { ctx[:current_user].present? }

    field :team_by_id, resolver: Queries::TeamByIdQuery

    field :viewer, resolver: Queries::ViewerQuery
  end
end
