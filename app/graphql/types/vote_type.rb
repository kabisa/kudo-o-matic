# frozen_string_literal: true

module Types
  VoteType = GraphQL::ObjectType.define do
    name 'Vote'

    field :id, !types.ID

    field :votable_type, !types.String, 'The object that is voted on'
    field :votable_id, !types.ID, 'The ID of the object that is voted on'

    field :voter_type, !types.String, 'The object that voted'
    field :voter_id, !types.ID, 'The ID of the object that voted'

    field :vote_weight, !types.Int, 'The weight of the vote (e.g. one vote is one like)'
  end
end