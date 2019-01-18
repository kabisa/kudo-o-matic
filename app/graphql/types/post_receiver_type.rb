# frozen_string_literal: true

module Types
  class PostReceiverType < BaseObject
    graphql_name "PostReceiver"

    field :id, ID, null: false
    field :user, UserType,
          null: false,
          description: 'The user it belongs to',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(User).load(obj.user_id) }
    field :post, PostType,
          null: false,
          description: 'The post it belongs to',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Post).load(obj.post_id) }
    field :created_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the PostReceiver was created'
    field :updated_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the PostReceiver was last updated'
  end
end
