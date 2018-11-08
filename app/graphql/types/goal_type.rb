# frozen_string_literal: true

module Types
  GoalType = GraphQL::ObjectType.define do
    name 'Goal'

    field :id, !types.ID
    field :name, !types.String
    field :amount, !types.Int
    field :achieved_on, Types::Date

    field :kudosMeter, Types::KudosMeterType do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(KudosMeter).load(obj.kudos_meter_id) }
    end
  end
end