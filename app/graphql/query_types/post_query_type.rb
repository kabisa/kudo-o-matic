# frozen_string_literal: true

module QueryTypes
  PostQueryType = GraphQL::ObjectType.define do
    name "PostQueryType"
    description "The post query type"

    # find all records
    connection :postsConnection, Connections::PostsConnection,  function: Functions::FindAll.new(Post)

    # find post by id
    field :postById, Types::PostType, function: Functions::FindById.new(Post)
  end
end
