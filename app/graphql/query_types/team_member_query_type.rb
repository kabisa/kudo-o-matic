# frozen_string_literal: true

module QueryTypes
  TeamMemberQueryType = GraphQL::ObjectType.define do
    name "TeamMemberQueryType"
    description "The team member query type"

    # find all records
    field :teamMembers, types[Types::TeamMemberType], function: Functions::FindAll.new(TeamMember) do
      argument :findByTeamId, !types.ID, 'Find team members that belong to a team'
    end

    # find team member by id
    field :teamMemberById, Types::TeamMemberType, function: Functions::FindById.new(TeamMember)
  end
end
