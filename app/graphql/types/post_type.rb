# frozen_string_literal: true

module Types
  PostType = GraphQL::ObjectType.define do
    name "Post"

    field :id, !types.ID
    field :message, !types.String
    field :amount, !types.Int

    field :sender, !Types::UserType do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(User).load(obj.sender_id) }
    end

    field :receivers, !types[Types::UserType] do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(User).load_many(obj.receivers.ids) }
    end
  end
end
