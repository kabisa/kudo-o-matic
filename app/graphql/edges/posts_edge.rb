# frozen_string_literal: true

module Edges
  class PostsEdge < GraphQL::Types::Relay::BaseEdge
    node_type(Types::PostType)
  end
end