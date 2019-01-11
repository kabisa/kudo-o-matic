# frozen_string_literal: true

RSpec.describe Queries::TeamByIdQuery do
  set_graphql_type

  let(:user) { create(:user) }
  let(:teams) { create_list(:team, 2) }
  let!(:team_invite) { create(:team_invite, email: user.email, team: teams.first) }
  let!(:team_invite_2) { create(:team_invite, email: user.email, team: teams.second) }
  let!(:team_invites) { create_list(:team_invite, 10, team: teams.first) }


  let(:variables) { { id: teams.first.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    res
  end
  let(:query_string) { %({ teamById(id: #{variables[:id]}) { teamInvites { id email } } }) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can query team invites' do
        query_result = []
        result['data']['teamById']['teamInvites'].each { |hash| query_result << hash unless hash.nil? }

        expect(query_result.count).to eq(11)
      end
    end

    describe 'user is team admin' do
      before do
        teams.first.add_member(user, 'admin')
      end

      it 'can query team invites if member of team' do
        query_result = []
        result['data']['teamById']['teamInvites'].each { |hash| query_result << hash unless hash.nil? }

        expect(query_result.count).to eq(11)
      end
    end

    describe 'user is team member' do
      before do
        team_invite.accept
      end

      it 'returns a not authorized error for TeamInvite.id' do
        expect(result['data']['teamById']).to be_nil
        expect(result['errors'].first['message']).to eq('Not authorized to access TeamInvite.id')
      end
    end

    describe 'user' do
      it 'returns a not authorized error for Team.teamInvites if user is not member of team' do
        expect(result['data']['teamById']).to be_nil
        expect(result['errors'].first['message']).to eq('Not authorized to access Team.teamInvites')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'returns a not authorized error for Query.teamById' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Query.teamById')

      expect(result['data']['teamById']).to be_nil
    end
  end
end