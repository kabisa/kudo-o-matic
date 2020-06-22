# frozen_string_literal: true

RSpec.describe Mutations::TeamInvite::DeclineInvite do
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
    %( mutation { declineTeamInvite(
      teamInviteId: "#{variables[:team_invite_id]}"
    ) { teamInvite { email team { id } } } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      let(:variables) { { team_invite_id: team_invite_2.id } }

      before do
        user.update(admin: true)
      end

      it 'can decline team invites' do
        result
        team_invite_2.reload
        expect(team_invite_2).to_not be_nil
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is invited user' do
      it 'can decline team invites' do
        result
        team_invite_2.reload
        expect(team_invite_2).to_not be_nil
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is not invited user' do
      let(:variables) { { team_invite_id: team_invite_2.id } }

      it 'can\'t decline the team invite' do
        expect(result['data']['declineTeamInvite']).to be_nil
      end

      it 'returns a not authorized error for Mutation.declineTeamInvite' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.declineTeamInvite')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t decline team invites' do
      expect(result['data']['declineTeamInvite']).to be_nil
    end

    it 'returns a not authorized error for Mutation.declineTeamInvite' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.declineTeamInvite')
    end
  end
end