# frozen_string_literal: true

module Types
  class KudosMeterType < BaseObject
    graphql_name 'KudosMeter'

    field :id, ID, null: false
    field :name, String,
          null: false,
          description: 'The name of the KudosMeter'
    field :amount, Int,
          null: false,
          description: 'The collect amount of kudos'
    field :goals, [Types::GoalType],
          null: false,
          description: 'The goals that belong to the KudosMeter' do
            argument :order_by, String, required: false, default_value: "amount asc"
          end

    def goals(order_by:)
      result = object.goals
      result = result.order(order_by) unless order_by.blank?
      result
    end

    field :team, Types::TeamType,
          null: false,
          description: 'The team the KudosMeter belongs to',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Team).load(obj.team_id) }
    field :created_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the KudosMeter was created'
    field :updated_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the KudosMeter was last updated'
  end
end
