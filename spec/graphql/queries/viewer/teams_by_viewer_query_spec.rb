# frozen_string_literal: true

RSpec.describe Queries::ViewerQuery do
  set_graphql_type

  let(:user) { create(:user) }
  let(:teams) { create_list(:team, 2) }
  let(:variables) { {} }
  let(:result) do
    res = KudoOMaticSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    res
  end
  let(:query_string) { %({ viewer { teams { id name slug } } }) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is team member' do
      before do
        teams.each { |team| team.add_member(user) }
      end

      it 'can query it\'s teams' do
        query_result = []
        result['data']['viewer']['teams'].each { |hash| query_result << hash unless hash.nil? }

        expect(query_result.count).to eq(2)
      end
    end

    describe 'user is not a team member' do
      it 'returns an empty array' do
        query_result = []
        result['data']['viewer']['teams'].each { |hash| query_result << hash unless hash.nil? }

        expect(query_result).to be_empty
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'returns a not authorized error for Query.viewer' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Query.viewer')

      expect(result['data']['viewer']).to be_nil
    end
  end
end