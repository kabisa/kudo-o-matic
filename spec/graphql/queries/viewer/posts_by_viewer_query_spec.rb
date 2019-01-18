# frozen_string_literal: true

RSpec.describe Queries::ViewerQuery do
  set_graphql_type

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
        receivers: [users.first],
        team: teams.second,
        kudos_meter: kudos_meter_2
    )
  end
  let(:variables) { { } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    res
  end

  context 'authenticated' do
    let(:context) { { current_user: users.first } }

    describe 'sent posts' do
      let(:query_string) { %({ viewer { sentPosts { id message amount } } }) }

      it 'can query it\'s sent posts' do
        expect(result['data']['viewer']['sentPosts'].count).to eq(3)
      end
    end

    describe 'received posts' do
      let(:query_string) { %({ viewer { receivedPosts { id message amount } } }) }

      it 'can query it\'s received posts' do
        expect(result['data']['viewer']['receivedPosts'].count).to eq(2)
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    describe 'sent posts' do
      let(:query_string) { %({ viewer { sentPosts { id message amount } } }) }

      it 'can\'t query any posts' do
        expect(result['data']['viewer']).to be_nil
      end

      it 'returns a not authorized error for Query.viewer' do
        expect(result['errors'].first['message']).to include('Not authorized to access Query.viewer')
      end
    end

    describe 'received posts' do
      let(:query_string) { %({ viewer { receivedPosts { id message amount } } }) }

      it 'can\'t query any posts' do
        expect(result['data']['viewer']).to be_nil
      end

      it 'returns a not authorized error for Query.viewer' do
        expect(result['errors'].first['message']).to include('Not authorized to access Query.viewer')
      end
    end
  end
end