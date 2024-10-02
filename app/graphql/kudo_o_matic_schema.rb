# frozen_string_literal: true

class KudoOMaticSchema < GraphQL::Schema
  max_depth 8 # max query nesting
  use GraphQL::Batch
  # use GraphQL::Guard.new( # authorization solution
  #   policy_object: Util::GraphqlPolicy,
  #   not_authorized: ->(type, field) do
  #     GraphQL::ExecutionError.new("Not authorized to access #{type}.#{field}")
  #   end
  # )

  query(Types::QueryType)
  mutation(Types::MutationType)
end
