# frozen_string_literal: true

RSpec.describe Queries::TeamByIdQuery do
  set_graphql_type

  let(:user) { create(:user) }
  let(:users) { create_list(:user, 5) }
  let(:teams) { create_list(:team, 2) }
  let(:kudos_meter) { teams.first.active_kudos_meter }
  let(:kudos_meter_2) { teams.second.active_kudos_meter }

  before do
    users.each { |user| teams.first.add_member(user) }
    users.each { |user| teams.second.add_member(user) }
  end

  let!(:posts) do
    create_list(
      :post, 3,
      sender: users.first,
      receivers: [users.second, users.last],
      team: teams.first,
      kudos_meter: kudos_meter
    )
  end
  let!(:other_posts) do
    create_list(
      :post, 2,
      sender: users.fourth,
      receivers: [users.fifth],
      team: teams.second,
      kudos_meter: kudos_meter_2
    )
  end
  let(:variables) { { id: teams.first.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    res
  end
  let(:query_string) { %({ teamById(id: #{variables[:id]}) { posts { totalCount edges { node { id message amount } } } } }) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can query all posts per team' do
        expect(result['data']['teamById']['posts']['totalCount']).to eq(3)
      end
    end

    describe 'user is team member' do
      it 'can query posts if member of team' do
        teams.first.add_member(user)
        expect(result['data']['teamById']['posts']['totalCount']).to eq(3)
      end
    end

    describe 'user' do
      it 'returns a not authorized error if user is not member of team' do
        expect(result['data']['teamById']).to be_nil
        expect(result['errors'].first['message']).to eq('Not authorized to access Team.posts')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }
    let(:variables) { { id: teams.first.id } }

    it 'can\'t query any posts' do
      expect(result['data']['teamById']).to be_nil
    end

    it 'returns a not authorized error for Query.teamById' do
      expect(result['errors'].first['message']).to include('Not authorized to access Query.teamById')
    end
  end
end