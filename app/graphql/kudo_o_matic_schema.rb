# frozen_string_literal: true

class KudoOMaticSchema < GraphQL::Schema
  use GraphQL::Batch

  mutation(Types::MutationType)
  query(Types::QueryType)
end
