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
  let(:query_string) { %({ teamById(id: #{variables[:id]}) { activeKudosMeter { id name amount } kudosMeters { id name amount } } } ) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can query the active kudos meter' do
        expect(result['data']['teamById']['activeKudosMeter']['id'].to_i).to eq(teams.first.active_kudos_meter.id)
      end

      it 'can query all kudos meters' do
        expect(result['data']['teamById']['kudosMeters'].count).to eq(1)
      end
    end

    describe 'user is team member' do
      it 'can query a kudos meter if member of team' do
        teams.first.add_member(user)
        expect(result['data']['teamById']['activeKudosMeter']['id'].to_i).to eq(teams.first.active_kudos_meter.id)
      end

      it 'can query all kudos meters if member of team' do
        teams.first.add_member(user)
        expect(result['data']['teamById']['kudosMeters'].count).to eq(1)
      end

      it 'returns a not authorized error if user is not member of team' do
        expect(result['data']['teamById']).to be_nil
        expect(result['errors'].first['message']).to eq('Not authorized to access Team.activeKudosMeter')
      end
    end

    describe 'user' do
      it 'returns a not authorized error if user is not member of team' do
        expect(result['data']['teamById']).to be_nil
        expect(result['errors'].first['message']).to eq('Not authorized to access Team.activeKudosMeter')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t query any kudos meters' do
      expect(result['data']['teamById']).to be_nil
    end

    it 'returns a not authorized error for Query.kudosMeterById' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Query.teamById')
    end
  end
end
