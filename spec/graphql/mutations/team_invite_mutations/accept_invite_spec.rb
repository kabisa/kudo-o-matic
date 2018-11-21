# frozen_string_literal: true

RSpec.describe Mutations::TeamInviteMutation, ":acceptInvite" do
  let!(:team) { create(:team) }
  let!(:user) { create(:user, email: "my@email.com") }

  context 'authenticated user' do
    describe "accept invite" do
      it 'sets the invite to accepted and creates a team member' do
        team_invite = create(:team_invite, email: "my@email.com", team: team)

        args = { team_invite_id: team_invite.id }
        ctx = { current_user: user }


        expect do
          subject.fields["acceptInvite"].resolve(nil, args, ctx)
        end.to change { TeamMember.count }.by(1)

        team_invite.reload
        expect(team_invite.accepted_at).to_not be_nil
      end

      it 'can\'t accept the invite if it\'s not found' do
        args = { team_invite_id: 100 }
        ctx = { current_user: user }

        expect do
          subject.fields["acceptInvite"].resolve(nil, args, ctx)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'can\'t accept the invite if the invite is already accepted or declined' do
        team_invite = create(:team_invite, :is_accepted, email: "my@email.com", team: team)

        args = { team_invite_id: team_invite.id }
        ctx = { current_user: user }

        query_result = subject.fields["acceptInvite"].resolve(nil, args, ctx)

        expect(query_result).to be_nil
      end

      it 'can\'t accept the invite if the invited email doesn\'t match the users email' do
        team_invite = create(:team_invite, email: "other@email.com", team: team)

        args = { team_invite_id: team_invite.id }
        ctx = { current_user: user }

        query_result = subject.fields["acceptInvite"].resolve(nil, args, ctx)

        expect(query_result).to be_nil
      end
    end
  end

  context 'unauthenticated user' do
    it 'can\'t accept the invitation' do
      team_invite = create(:team_invite, email: "my@email.com", team: team)

      args = { team_invite_id: team_invite.id }
      ctx = { current_user: nil }

      expect do
        subject.fields["acceptInvite"].resolve(nil, args, ctx)
      end.to raise_error(GraphQL::ExecutionError, "Authentication required")
    end
  end
end
