# frozen_string_literal: true

module Types
  class GoalType < BaseObject
    graphql_name 'Goal'

    field :id, ID, null: false
    field :name, String,
          null: false,
          description: 'The name of the goal'
    field :amount, Int,
          null: false,
          description: 'The amount of kudos that is required to reach the goal'
    field :achieved_on, Types::Date,
          null: true,
          description: 'The date the goal is achieved'
    field :kudosMeter, Types::KudosMeterType,
          null: false,
          description: 'The kudos meter the goal belongs to',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(KudosMeter).load(obj.kudos_meter_id) }
  end
end