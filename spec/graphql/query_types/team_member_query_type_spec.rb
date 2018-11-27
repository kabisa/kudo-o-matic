# frozen_string_literal: true

RSpec.describe QueryTypes::TeamMemberQueryType do
  # avail type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  let(:team) { create(:team) }
  let(:team_2) { create(:team) }

  let(:user) { create(:user) }
  let(:user_2) { create(:user) }
  let(:user_3) { create(:user) }

  let!(:team_member) { create(:team_member, user: user, team: team) }
  let!(:team_member_1) { create(:team_member, user: user_2, team: team) }
  let!(:team_member_2) { create(:team_member, user: user_3, team: team_2) }

  let!(:team_members) { team.memberships }

  describe "querying all team members" do
    it "has a :teamMembers field that returns [TeamMember]" do
      expect(subject).to have_field(:teamMembers).that_returns('[TeamMember]')
    end

    it 'accepts a orderBy argument, of type String' do
      expect(subject.fields["teamMembers"]).to accept_arguments(orderBy: 'String')
    end

    it 'accepts a required findByTeamId argument, of type ID' do
      expect(subject.fields["teamMembers"]).to accept_arguments(findByTeamId: 'ID!')
    end

    it "returns all team members of a team" do
      args = { findByTeamId: team.id }
      query_result = subject.fields["teamMembers"].resolve(nil, args, nil)

      team_members.each do |member|
        expect(query_result).to include(member)
      end

      expect(query_result.count).to eq(team_members.count)
    end
  end

  describe "querying a specific team by id" do
    it "has a field :teamMemberById that returns a TeamMember" do
      expect(subject).to have_field(:teamMemberById).that_returns('TeamMember')
    end

    it 'accepts a id argument, of type !ID' do
      expect(subject.fields["teamMemberById"]).to accept_argument(id: 'ID!')
    end

    it "returns the queried team member" do
      id = TeamMember.first.id
      args = { id: id }
      query_result = subject.fields["teamMemberById"].resolve(nil, args, nil)

      expect(query_result).to eq(TeamMember.first)
    end
  end
end
