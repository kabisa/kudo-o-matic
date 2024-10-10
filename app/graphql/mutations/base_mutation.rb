module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    field_class Types::BaseField

    # methods that should be inherited can go here.
    # like a `current_tenant` method, or methods related
    # to the `context` object
  end
end