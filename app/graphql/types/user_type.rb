# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    graphql_name "User"

    field :id, ID, null: false
    field :name, String,
          null: false,
          description: 'The name of the user'
    field :email, EmailAddress,
          null: false,
          description: 'The email address of the user'
    field :avatar, String,
          null: false,
          description: 'The avatar of the user',
          method: :picture_url
    field :sent_posts, [PostType],
          null: false,
          description: 'The posts that are sent by the user',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Post).load_many(obj.sent_posts.ids) }
    field :received_posts, [PostType],
          null: false,
          description: 'The posts that are received by the user',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Post).load_many(obj.received_posts.ids) }
    field :team_invites, [TeamInviteType],
          null: false,
          description: 'The invites for the user',
          resolve: ->(obj, _args, _ctx) do
            Util::RecordLoader.for(TeamInvite).load_many(TeamInvite.where(email: obj.email).open.ids)
          end
    field :memberships, [TeamMemberType],
          null: false,
          description: 'The memberships of the user',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(TeamMember).load_many(obj.membership_ids) }
    field :teams, [TeamType],
          null: false,
          description: 'The teams that the user is member of',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Team).load_many(obj.team_ids) }
    field :admin, Boolean,
          null: true,
          description: 'Is the user application administrator?'
    field :virtual_user, Boolean,
          null: true,
          description: 'Is the user a virtual user?'
    field :unlock_token, String,
          null: true,
          description: 'Slack connect token, misusing an existing field for now'
    field :slack_id, String,
          null: true,
          description: 'Slack id'
  end
end
