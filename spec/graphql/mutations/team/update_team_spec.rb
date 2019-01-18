# frozen_string_literal: true

RSpec.describe Mutations::Team::UpdateTeam do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }

  let(:variables) { { name: 'The updated team name', team_id: team.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { updateTeam(
      name: "#{variables[:name]}"
      teamId: "#{variables[:team_id]}"
    ) { team { id name } errors } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can update a team' do
        expect(result['data']['updateTeam']['team']['id'].to_i).to eq(variables[:team_id])
        expect(result['data']['updateTeam']['team']['name']).to eq(variables[:name])
      end

      it 'returns no errors' do
        expect(result['data']['updateTeam']['errors']).to be_empty
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can update a team' do
        expect(result['data']['updateTeam']['team']['id'].to_i).to eq(variables[:team_id])
        expect(result['data']['updateTeam']['team']['name']).to eq(variables[:name])
      end

      it 'returns no errors' do
        expect(result['data']['updateTeam']['errors']).to be_empty
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t update a team' do
        expect(result['data']['updateTeam']).to be_nil
      end

      it 'returns a not authorized error for Mutation.updateTeam' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateTeam')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t update a team' do
        expect(result['data']['updateTeam']).to be_nil
      end

      it 'returns a not authorized error for Mutation.updateTeam' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateTeam')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t create a team' do
      expect(result['data']['updateTeam']).to be_nil
    end

    it 'returns a not authorized error for Mutation.updateTeam' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateTeam')
    end
  end
end