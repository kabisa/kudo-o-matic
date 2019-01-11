module Types
  class TeamInviteType < BaseObject
    graphql_name 'TeamInvite'

    field :id, ID, null: false
    field :email, Types::EmailAddress,
          null: false,
          description: 'The email address that receives the invite'
    field :team, Types::TeamType,
          null: false,
          description: 'The team that sends the invite',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Team).load(obj.team_id) }
    field :sent_at, GraphQL::Types::ISO8601DateTime,
          null: true,
          description: 'The DateTime that the invite is sent'
    field :accepted_at, GraphQL::Types::ISO8601DateTime,
          null: true,
          description: 'The DateTime that the invite is accepted'
    field :declined_at, GraphQL::Types::ISO8601DateTime,
          null: true,
          description: 'The DateTime that the invite is declined'
  end
end