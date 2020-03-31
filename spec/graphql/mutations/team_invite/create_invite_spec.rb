# frozen_string_literal: true

RSpec.describe Mutations::TeamInvite::CreateInvite do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }

  let(:variables) { { team_id: team.id, emails: ['test@example.com', 'test_2@example.com'] } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:result_1) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { createTeamInvite(
      teamId: "#{variables[:team_id]}"
      emails: #{variables[:emails]}
    ) { teamInvites { email team { id } } } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can create team invites' do
        expect { result }.to change { team.team_invites.count }.by(2)
        .and change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(2)
        .and have_enqueued_job(ActionMailer::DeliveryJob)
          .with('UserMailer', 'invite_email', 'deliver_now', variables[:emails][0], team)
          .with('UserMailer', 'invite_email', 'deliver_now', variables[:emails][1], team)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end

      it 'returns error if email addresses are already invited to team' do
        result
        expect(result_1['errors'].first['message']).to eq(
          'Email test@example.com is already invited, Email test_2@example.com is already invited'
        )
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can create team invites' do
        expect { result }.to change { team.team_invites.count }.by(2)
        .and change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(2)
        .and have_enqueued_job(ActionMailer::DeliveryJob)
          .with('UserMailer', 'invite_email', 'deliver_now', variables[:emails][0], team)
          .with('UserMailer', 'invite_email', 'deliver_now', variables[:emails][1], team)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end

      it 'returns error if email addresses are already invited to team' do
        result
        expect(result_1['errors'].first['message']).to eq(
          'Email test@example.com is already invited, Email test_2@example.com is already invited'
        )
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t create team invites' do
        expect { result }.to_not change { team.team_invites.count }
        expect { result }.to_not change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }
      end

      it 'returns a not authorized error for Mutation.createTeamInvite' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createTeamInvite')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t create team invites' do
        expect { result }.to_not change { team.team_invites.count }
        expect { result }.to_not change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }
        expect(result['data']['createTeamInvite']).to be_nil
      end

      it 'returns a not authorized error for Mutation.createTeamInvite' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createTeamInvite')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t create team invites' do
      expect(result['data']['createTeamInvite']).to be_nil
    end

    it 'returns a not authorized error for Mutation.createTeamInvite' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createTeamInvite')
    end
  end
end