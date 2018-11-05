# frozen_string_literal: true

module Types
  PostReceiverType = GraphQL::ObjectType.define do
    name "PostReceiver"

    field :id, !types.ID

    field :userId, !Types::UserType do
      resolve ->(obj, args, context) { Util::RecordLoader.for(User).load(obj.user_id) }
    end
    field :postId, !Types::PostType do
      resolve ->(obj, args, context) { Util::RecordLoader.for(Post).load(obj.post_id) }
    end
  end
end
