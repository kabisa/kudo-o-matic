module Types
  TeamInviteType = GraphQL::ObjectType.define do
    name 'TeamInvite'

    field :id, !types.ID
    field :email, !Types::EmailAddress, 'The email address that receives the invite'

    field :team, !Types::TeamType, 'The team that sends the invite' do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Team).load(obj.team_id) }
    end

    field :sentAt, GraphQL::Types::ISO8601DateTime, 'The DateTime that the invite is sent',
          property: :sent_at
    field :acceptedAt, GraphQL::Types::ISO8601DateTime, 'The DateTime that the invite is accepted',
          property: :accepted_at
    field :declinedAt, GraphQL::Types::ISO8601DateTime, 'The DateTime that the invite is declined',
          property: :declined_at
  end
end