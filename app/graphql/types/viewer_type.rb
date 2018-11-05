# frozen_string_literal: true

module Types
  ViewerType = GraphQL::ObjectType.define do
    name "ViewerType"

    field :self, Types::UserType do
      resolve ->(object, _a, _c) do
        object
      end
    end
  end
end
