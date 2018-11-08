# frozen_string_literal: true

module QueryTypes
  KudosMeterQueryType = GraphQL::ObjectType.define do
    name "KudosMeterQueryType"
    description "The kudos meter query type"

    # find all records
    field :kudosMeters, types[Types::KudosMeterType], function: Functions::FindAll.new(KudosMeter)

    field :kudosMeterById, Types::KudosMeterType, function: Functions::FindById.new(KudosMeter)
  end
end
