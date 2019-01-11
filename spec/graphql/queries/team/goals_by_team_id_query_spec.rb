# frozen_string_literal: true

RSpec.describe Queries::TeamByIdQuery do
  set_graphql_type

  let(:user) { create(:user) }
  let(:teams) { create_list(:team, 2) }

  let(:variables) { { id: teams.first.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    res
  end
  let(:query_string) { %({ teamById(id: #{variables[:id]}) { activeGoals { id name amount } goals { id name amount } } } ) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can query the active goals' do
        query_result = []

        result['data']['teamById']['activeGoals'].each { |hash| query_result << hash['id'].to_i unless hash.nil? }
        expect(query_result).to eq(teams.first.active_kudos_meter.goal_ids)
      end

      it 'can query all goals' do
        expect(result['data']['teamById']['goals'].count).to eq(3)
      end
    end

    describe 'user is team member' do
      it 'can query the active goals if member of team' do
        teams.first.add_member(user)
        query_result = []
        result['data']['teamById']['activeGoals'].each { |hash| query_result << hash['id'].to_i unless hash.nil? }
        expect(query_result).to eq(teams.first.active_kudos_meter.goal_ids)
      end

      it 'can query all kudos meters if member of team' do
        teams.first.add_member(user)
        expect(result['data']['teamById']['goals'].count).to eq(3)
      end
    end

    describe 'user' do
      it 'returns a not authorized error if user is not member of team' do
        expect(result['data']['teamById']).to be_nil
        expect(result['errors'].first['message']).to eq('Not authorized to access Team.activeGoals')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t query any kudos meters' do
      expect(result['data']['teamById']).to be_nil
    end

    it 'returns a not authorized error for Query.teamById' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Query.teamById')
    end
  end
end
