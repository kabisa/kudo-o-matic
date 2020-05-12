# frozen_string_literal: true

RSpec.describe Mutations::TeamMember::UpdateRole do
  set_graphql_type

  let!(:user) { create(:user) }
  let!(:users) { create_list(:user, 5) }
  let!(:team) { create(:team) }

  before do
    users.each { |user| team.add_member(user) }
  end

  let(:variables) { { role: 'admin', user_id: users.first.id, team_id: team.id } }

  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { updateTeamMemberRole(
      role: #{variables[:role]}
      userId: "#{variables[:user_id]}"
      teamId: "#{variables[:team_id]}"
    ) { teamMember { id role user { id } team { id } } } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can update a team member' do
        expect(result['data']['updateTeamMemberRole']['teamMember']['user']['id'].to_i).to eq(users.first.id)
        expect(result['data']['updateTeamMemberRole']['teamMember']['team']['id'].to_i).to eq(team.id)
        expect(result['data']['updateTeamMemberRole']['teamMember']['role']).to eq('admin')
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can update a team member' do
        expect(result['data']['updateTeamMemberRole']['teamMember']['user']['id'].to_i).to eq(users.first.id)
        expect(result['data']['updateTeamMemberRole']['teamMember']['team']['id'].to_i).to eq(team.id)
        expect(result['data']['updateTeamMemberRole']['teamMember']['role']).to eq('admin')
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is last team admin' do
      before do
        team.add_member(user, 'admin')
      end

      let(:variables) { { role: 'member', user_id: user.id, team_id: team.id } }

      it 'can\'t update a team member if that member is the only team admin' do
        expect(result['errors'].first['message']).to eq("role: 'admin' should be assigned to at least 1 other team member.")
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t update a team member' do
        expect(result['data']['updateTeamMemberRole']).to be_nil
      end

      it 'returns no errors' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateTeamMemberRole')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t update a team member' do
        expect(result['data']['updateTeamMemberRole']).to be_nil
      end

      it 'returns no errors' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateTeamMemberRole')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t create a post' do
      expect(result['data']['updateTeamMemberRole']).to be_nil
    end

    it 'returns a not authorized error for Mutation.updateTeamMemberRole' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateTeamMemberRole')
    end
  end
end