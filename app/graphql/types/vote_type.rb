# frozen_string_literal: true

module Types
  class VoteType < BaseObject
    graphql_name 'Vote'

    field :id, ID, null: false
    field :voted_on, Types::PostType,
          null: false,
          description: 'The post that the user voted on',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Post).load(obj.votable_id) }
    field :voter, Types::UserType,
          null: false,
          description: 'The user that voted on the Post',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(User).load(obj.voter_id) }
    field :vote_weight, Int,
          null: false,
          description: 'The weight of the vote (e.g. one vote is one like)'
  end
end