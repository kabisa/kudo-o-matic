# frozen_string_literal: true

module Types
  UserType = GraphQL::ObjectType.define do
    name "User"

    field :id, !types.ID
    field :name, !types.String
    field :email, !Types::EmailAddress

    field :sentPosts, !types[Types::PostType], 'The sent posts of the user' do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Post).load_many(obj.sent_posts.ids) }
    end

    field :receivedPosts, !types[Types::PostType], 'The received posts of the user' do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Post).load_many(obj.received_posts.ids) }
    end

    field :teamInvites, !types[Types::TeamInviteType], 'The invites for the user' do
      resolve ->(obj, args, ctx) do
        Util::RecordLoader.for(TeamInvite).load_many(TeamInvite.where(email: obj.email).ids)
      end
    end
  end
end
