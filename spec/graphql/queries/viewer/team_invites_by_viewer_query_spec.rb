# frozen_string_literal: true

RSpec.describe Queries::ViewerQuery do
  set_graphql_type

  let(:user) { create(:user) }
  let(:teams) { create_list(:team, 2) }
  let!(:team_invite) { create(:team_invite, email: user.email, team: teams.first) }
  let!(:team_invite_2) { create(:team_invite, email: user.email, team: teams.second) }
  let!(:team_invites) { create_list(:team_invite, 10, team: teams.first) }
  let(:variables) { {} }
  let(:result) do
    res = KudoOMaticSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    res
  end
  let(:query_string) { %({ viewer { teamInvites { id email team { name } } } }) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    it 'can query it\'s own invites' do
      query_result = []
      result['data']['viewer']['teamInvites'].each { |hash| query_result << hash unless hash.nil? }

      expect(query_result.count).to eq(2)
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