# frozen_string_literal: true

module Types
  class PostType < Types::BaseObject
    graphql_name "Post"

    field :id, ID, null: false
    field :message, String,
          null: false,
          description: 'The reason the kudos are given'
    field :amount, Int,
          null: false,
          description: 'The amount of kudos that are given'
    field :image_urls, [String],
          null: false,
          description: 'Optional image attached to this post'
    field :sender, UserType,
          null: false,
          description: 'The sender of the post',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(User).load(obj.sender_id) }
    field :receivers, [UserType],
          null: false,
          description: 'The receiver(s) of the post',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(User).load_many(obj.receivers.ids) }
    field :team, TeamType,
          null: false,
          description: 'The team the post belongs to',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Team).load(obj.team_id) }
    field :kudos_meter, KudosMeterType,
          null: false,
          description: 'The kudometer that collects the kudos of the post',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(KudosMeter).load(obj.kudos_meter_id) }
    field :votes, [VoteType],
          null: false,
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Vote).load_many(obj.votes.ids) }
    field :created_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the post was created'
    field :updated_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the post was last updated'

    def image_urls
        object.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image, only_path: false) }
    end
  end
end
