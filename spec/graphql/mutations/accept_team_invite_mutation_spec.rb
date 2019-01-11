# frozen_string_literal: true

RSpec.describe Mutations::AcceptTeamInviteMutation do
  set_graphql_type

  let(:user) { create(:user) }
  let(:user_2) { create(:user) }
  let(:team) { create(:team) }
  let(:team_invite) { create(:team_invite, email: user.email, team: team) }
  let(:team_invite_2) { create(:team_invite, email: user_2.email, team: team) }
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
    %( mutation { acceptTeamInvite(
      teamInviteId: "#{variables[:team_invite_id]}"
    ) { teamInvite { email team { id } } errors } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      let(:variables) { { team_invite_id: team_invite_2.id } }

      before do
        user.update(admin: true)
      end

      it 'can accept team invites' do
        expect { result }.to change { team.users.count }.by(1)
      end

      it 'returns no errors' do
        expect(result['data']['acceptTeamInvite']['errors']).to be_empty
      end
    end

    describe 'user is invited user' do
      it 'can accept team invites' do
        expect { result }.to change { team.users.count }.by(1)
      end

      it 'returns no errors' do
        expect(result['data']['acceptTeamInvite']['errors']).to be_empty
      end
    end

    describe 'user is not invited user' do
      let(:variables) { { team_invite_id: team_invite_2.id } }

      it 'can\'t accept the team invite' do
        expect(result['data']['acceptTeamInvite']).to be_nil
      end

      it 'returns a not authorized error for Mutation.acceptTeamInvite' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.acceptTeamInvite')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t accept team invites' do
      expect(result['data']['acceptTeamInvite']).to be_nil
    end

    it 'returns a not authorized error for Mutation.acceptTeamInvite' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.acceptTeamInvite')
    end
  end
end