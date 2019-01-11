# frozen_string_literal: true

RSpec.describe Queries::TeamByIdQuery do
  set_graphql_type

  let(:user) { create(:user) }
  let(:teams) { create_list(:team, 2) }
  let!(:guidelines) { create_list(:guideline, 10, team: teams.first) }
  let!(:guidelines_2) { create_list(:guideline, 15, team: teams.second) }

  let(:variables) { { id: teams.first.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    res
  end
  let(:query_string) { %({ teamById(id: #{variables[:id]}) { guidelines { id name kudos } } }) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can query guidelines' do
        query_result = []
        result['data']['teamById']['guidelines'].each { |hash| query_result << hash unless hash.nil? }

        expect(query_result.count).to eq(10)
      end
    end

    describe 'user is team member' do
      it 'can query guidelines if member of team' do
        teams.first.add_member(user)
        query_result = []
        result['data']['teamById']['guidelines'].each { |hash| query_result << hash unless hash.nil? }

        expect(query_result.count).to eq(10)
      end
    end

    describe 'user' do
      it 'returns a not authorized error if user is not member of team' do
        expect(result['data']['teamById']).to be_nil
        expect(result['errors'].first['message']).to eq('Not authorized to access Team.guidelines')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t query any guidelines' do
      expect(result['data']['teamById']).to be_nil
    end

    it 'returns a not authorized error for Query.teamById' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Query.teamById')
    end
  end
end
