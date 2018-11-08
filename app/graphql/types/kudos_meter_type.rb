# frozen_string_literal: true

module Types
  KudosMeterType = GraphQL::ObjectType.define do
    name "KudosMeter"

    field :id, !types.ID
    field :name, !types.String
    field :amount, !types.Int

    field :team, !Types::TeamType
  end
end
