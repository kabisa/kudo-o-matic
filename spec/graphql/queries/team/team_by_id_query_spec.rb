# frozen_string_literal: true

RSpec.describe Queries::TeamByIdQuery do
  set_graphql_type

  it 'subject returns Team' do
    expect(subject.type.to_type_signature).to eq ('Team')
  end

  describe 'query arguments' do
    it 'accepts a id argument of ID! type' do
      expect(subject.arguments['id'].type.to_type_signature).to eq('ID!')
    end
  end

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
  let(:query_string) { %({ teamById(id: #{variables[:id]}) { id name slug } }) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can query a team by id' do
        expect(result['data']['teamById']['id'].to_i).to eq(teams.first.id)
      end
    end

    describe 'user is team member' do
      it 'can query a team by id if member of team' do
        teams.first.add_member(user)
        expect(result['data']['teamById']['id'].to_i).to eq(teams.first.id)
      end
    end

    describe 'user' do
      it 'returns a not authorized error if user is not member of team' do
        expect(result['data']['teamById']).to be_nil
        expect(result['errors'].first['message']).to eq('Not authorized to access Team.id')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t query any teams' do
      expect(result['data']['teamById']).to be_nil
    end

    it 'returns a not authorized error for Query.teamById' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Query.teamById')
    end
  end
end