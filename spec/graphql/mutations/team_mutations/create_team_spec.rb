# frozen_string_literal: true

RSpec.describe Mutations::TeamMutation, ":createTeam" do
  let(:user) { create(:user) }

  describe 'create a team' do
    it 'creates a team if user is authenticated' do
      ctx = { current_user: user }
      args = { name: "Kabisa" }

      expect do
        subject.fields['createTeam'].resolve(nil, args, ctx)
      end.to change { Team.count }.by(1)
      .and change { TeamMember.count }.by(2)

      team_member = TeamMember.where(user: user, team: Team.last).first
      expect(team_member.role).to eq('admin')
    end

    it 'returns if user is not authenticated' do
      ctx = { current_user: nil }
      args = { name: "Kabisa" }

      expect do
        subject.fields['createTeam'].resolve(nil, args, ctx)
      end.to raise_error(GraphQL::ExecutionError, 'Authentication required')
    end
  end
end