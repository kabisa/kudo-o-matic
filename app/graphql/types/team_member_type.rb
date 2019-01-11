module Types
  class TeamMemberType < BaseObject
    graphql_name 'TeamMember'

    field :id, ID, null: false
    field :team, Types::TeamType,
          null: false,
          description: 'The team that the team member belongs to',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Team).load(obj.team_id) }
    field :user, Types::UserType,
          null: false,
          description: 'The user that belongs to a team',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(User).load(obj.user_id) }
    field :role, String,
          null: false,
          description: 'The role of the team member (member, moderator or admin)'
    field :created_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the team member was created'
    field :updated_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the team member was last updated'
  end
end