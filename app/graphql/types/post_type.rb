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

    field :team, !Types::TeamType do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Team).load(obj.team_id) }
    end

    field :kudosMeter, !Types::KudosMeterType do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(KudosMeter).load(obj.kudos_meter_id) }
    end

    field :votes, !types[Types::VoteType] do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Vote).load_many(obj.votes.ids) }
    end
  end
end
