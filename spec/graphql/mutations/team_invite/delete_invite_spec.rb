# frozen_string_literal: true

RSpec.describe Mutations::TeamInvite::DeleteInvite do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let!(:team_invite) { create(:team_invite, email: ['john@example.com'], team: team) }

  let(:variables) { { team_invite_id: team_invite.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { deleteTeamInvite(
      teamInviteId: "#{variables[:team_invite_id]}"
    ) { teamInviteId } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can delete team invites' do
        expect { result }.to change { team.team_invites.count }.by(-1)
        expect(result['data']['deleteTeamInvite']['teamInviteId'].to_i).to eq(variables[:team_invite_id])
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can delete team invites' do
        expect { result }.to change { team.team_invites.count }.by(-1)
        expect(result['data']['deleteTeamInvite']['teamInviteId'].to_i).to eq(variables[:team_invite_id])
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t delete team invites' do
        expect { result }.to_not change { team.team_invites.count }
        expect { result }.to_not change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }
      end

      it 'returns a not authorized error for Mutation.deleteTeamInvite' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteTeamInvite')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t delete team invites' do
        expect { result }.to_not change { team.team_invites.count }
        expect { result }.to_not change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }
        expect(result['data']['deleteTeamInvite']).to be_nil
      end

      it 'returns a not authorized error for Mutation.deleteTeamInvite' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteTeamInvite')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t delete team invites' do
      expect(result['data']['deleteTeamInvite']).to be_nil
    end

    it 'returns a not authorized error for Mutation.deleteTeamInvite' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteTeamInvite')
    end
  end
end