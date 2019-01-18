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
  let(:query_string) { %({ viewer { memberships { id user { id } team { id } } } }) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    it 'can query it\'s memberships' do
      team_invite.accept
      team_invite_2.accept
      expect(result['data']['viewer']['memberships'].count).to eq(2)
    end

    it 'returns an empty array if no memberships' do
      expect(result['data']['viewer']['memberships']).to be_empty
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