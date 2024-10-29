# frozen_string_literal: true

class KudoOMaticSchema < GraphQL::Schema
  max_depth 8 # max query nesting
  use GraphQL::Batch

  # Security policies, and the custom 'resolve:' key for graphql fields are
  # implemented BaseField class. This class is used as the field_class for
  # the BaseObject class. This way, all fields in the schema will inherit
  # the security policies and the custom 'resolve' key.

  query(Types::QueryType)
  mutation(Types::MutationType)
end
