RSpec.describe Mutations::Team::RemoveSlack do
  set_graphql_type

  let(:user) { create(:user) }
  let(:context) { {current_user: user} }
  let(:team) { create(:team, :with_slack) }
  let(:variables) { {team_id: team.id} }

  let(:mutation_string) do
    %( mutation { removeSlack(
      teamId: "#{variables[:team_id]}"
    ) { team { name } } } )
  end

  let(:result) do
    res = KudoOMaticSchema.execute(
        mutation_string,
        context: context,
        variables: variables
    )
    res
  end

  context 'authenticated' do
    describe 'user is an admin' do
      before do
        user.update(admin: true)
      end

      it 'removes the slack id, channel id and access token' do
        expect {
          result
          team.reload
        }.to change { team.slack_team_id }.to(nil).and \
             change { team.slack_bot_access_token }.to(nil).and \
             change { team.channel_id }.to(nil)
      end

      it 'returns no errors' do
        expect(result['errors']).to be(nil)
      end
    end

    describe 'user is a team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'removes the slack id, channel id and access token' do
        expect {
          result
          team.reload
        }.to change { team.slack_team_id }.to(nil).and \
             change { team.slack_bot_access_token }.to(nil).and \
             change { team.channel_id }.to(nil)
      end

      it 'returns no errors' do
        expect(result['errors']).to be(nil)
      end

    end

    describe 'user is not a member' do
      before do
        team.add_member(user, 'member')
      end

      it 'does not remove slack' do
        expect {
          result
        }.to_not change { team.slack_team_id }
      end

      it 'returns an error' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.removeSlack')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { {current_user: nil} }

    it 'can\'t remove slack from a team' do
      expect(result['data']['removeSlack']).to be_nil
    end

    it 'returns a not authorized error for Mutation.removeSlack' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.removeSlack')
    end
  end
end
