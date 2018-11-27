module Types
  TeamMemberType = GraphQL::ObjectType.define do
    name 'TeamMember'

    field :id, !types.ID

    field :team, !Types::TeamType, 'The team that the team member belongs to' do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Team).load(obj.team_id) }
    end

    field :user, !Types::UserType, 'The user that belongs to a team' do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(User).load(obj.user_id) }
    end

    field :role, !types.String, 'The role of the team member (member, moderator or admin)'

    field :createdAt, GraphQL::Types::ISO8601DateTime, 'The time the team member was created',
          property: :created_at
    field :updatedAt, GraphQL::Types::ISO8601DateTime, 'The time the team member was last updated',
          property: :updated_at
  end
end