# frozen_string_literal: true

module Types
  VoteType = GraphQL::ObjectType.define do
    name 'Vote'

    field :id, !types.ID

    field :votedOn, !Types::PostType, 'The post that the user voted on' do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Post).load(obj.votable_id) }
    end

    field :voter, !Types::UserType, 'The user that voted on the Post' do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(User).load(obj.voter_id) }
    end

    field :vote_weight, !types.Int, 'The weight of the vote (e.g. one vote is one like)'
  end
end