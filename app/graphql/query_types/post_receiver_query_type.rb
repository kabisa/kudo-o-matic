# frozen_string_literal: true

module QueryTypes
  PostReceiverQueryType = GraphQL::ObjectType.define do
    name "PostReceiverQueryType"
    description "The post receiver query type"

    # Retrieve all postreceivers
    field :postReceivers, types[Types::PostReceiverType], function: Functions::FindAll.new(PostReceiver)
  end
end
