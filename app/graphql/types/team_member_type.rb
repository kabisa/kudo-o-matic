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
  end
end