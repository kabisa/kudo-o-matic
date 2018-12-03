# frozen_string_literal: true

RSpec.describe Mutations::TeamInviteMutation, ":createInvite" do
  let!(:team) { create(:team) }
  let!(:user) { create(:user) }
  let!(:user_2) { create(:user, email: "my@email.com") }

  context 'authenticated user' do
    describe "user is team administrator" do
      it 'can create one invite' do
        team.add_member(user, 'admin')
        args = { team_id: team.id, emails: ["my@email.com"] }
        ctx = { current_user: user }

        expect do
          subject.fields["createInvite"].resolve(nil, args, ctx)
        end.to change { TeamInvite.count && ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'can create multiple invites' do
        team.add_member(user, 'admin')
        args = { team_id: team.id, emails: ["my@email.com", "your@email.com"] }
        ctx = { current_user: user }

        expect do
          subject.fields["createInvite"].resolve(nil, args, ctx)
        end.to change { TeamInvite.count && ActionMailer::Base.deliveries.count }.by(2)
      end

      it 'creates only one invite per email address' do
        team.add_member(user, 'admin')
        args = { team_id: team.id, emails: ["my@email.com", "my@email.com"] }
        ctx = { current_user: user }

        expect do
          subject.fields["createInvite"].resolve(nil, args, ctx)
        end.to change {
          TeamInvite.count
          ActionMailer::Base.deliveries.count
        }.by(1)
      end

      it 'creates no invites if one teaminvite is not valid' do
        team.add_member(user, 'admin')
        args = { team_id: team.id, emails: ['my@email.com', ''] }
        ctx = { current_user: user }

        expect do
          subject.fields["createInvite"].resolve(nil, args, ctx)
        end.to raise_error(GraphQL::ExecutionError, 'Email can\'t be blank')
      end
    end

    describe "user is team member" do
      it 'can\'t create an invite' do
        team.add_member(user)
        args = { team_id: team.id, email: "my@email.com" }
        ctx = { current_user: user }

        expect do
          subject.fields["createInvite"].resolve(nil, args, ctx)
        end.to raise_error(GraphQL::ExecutionError, "Failed to create invite: Permission denied.")
      end
    end

    describe "not a member" do
      it 'can\'t create an invite' do
        args = { team_id: team.id, email: "my@email.com" }
        ctx = { current_user: user }

        expect do
          subject.fields["createInvite"].resolve(nil, args, ctx)
        end.to raise_error(GraphQL::ExecutionError, "Failed to create invite: You are not a member of this team.")
      end
    end
  end

  context 'unauthenticated user' do
    it 'can\'t create an invite' do
      team_invite = create(:team_invite, email: "my@email.com", team: team)

      args = { team_invite_id: team_invite.id }
      ctx = { current_user: nil }

      expect do
        subject.fields["acceptInvite"].resolve(nil, args, ctx)
      end.to raise_error(GraphQL::ExecutionError, "Authentication required")
    end
  end
end
