# frozen_string_literal: true

module Connections
  class PostsConnection < GraphQL::Types::Relay::BaseConnection
    edge_type(Edges::PostsEdge)

    field :total_count, Int, null: false

    def total_count
      object.nodes.size
    end

  end
end

