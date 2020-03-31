# frozen_string_literal: true

RSpec.describe Mutations::TeamMember::DeleteMember do
  set_graphql_type

  let!(:user) { create(:user) }
  let!(:users) { create_list(:user, 5) }
  let!(:team) { create(:team) }

  before do
    users.each { |user| team.add_member(user) }
  end

  let(:variables) { { id: team.memberships.second.id } }

  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { deleteTeamMember(
      id: "#{variables[:id]}"
    ) { teamMemberId } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can delete a team member' do
        expect { result }.to change { team.memberships.count }.by(-1)
        expect(result['data']['deleteTeamMember']['teamMemberId'].to_i).to eq(variables[:id])
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can delete a team member' do
        expect { result }.to change { team.memberships.count }.by(-1)
        expect(result['data']['deleteTeamMember']['teamMemberId'].to_i).to eq(variables[:id])
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is last team admin' do
      before do
        team.add_member(user, 'admin')
      end

      let(:variables) { { id: TeamMember.find_by_user_id(user.id).id } }

      it 'can\'t delete a team member if that member is the only team admin' do
        expect(result['errors'].first['message']).to eql("Role 'admin' should be assigned to at least 1 other team member.")
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t delete a team member' do
        expect(result['data']['deleteTeamMember']).to be_nil
      end

      it 'returns an unauthorised error' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteTeamMember')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t delete a team member' do
        expect(result['data']['deleteTeamMember']).to be_nil
      end

      it 'returns an unauthorised error' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteTeamMember')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t create a post' do
      expect(result['data']['deleteTeamMember']).to be_nil
    end

    it 'returns an unauthorised error' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteTeamMember')
    end
  end
end