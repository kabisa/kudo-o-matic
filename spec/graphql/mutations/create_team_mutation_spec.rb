# frozen_string_literal: true

RSpec.describe Mutations::CreateTeamMutation do
  set_graphql_type

  let(:user) { create(:user) }
  let(:context) { { current_user: user } }
  let(:variables) { { name: 'Kabisa' } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { createTeam(
      name: "#{variables[:name]}"
    ) { team { name } errors } } )
  end

  context 'authenticated' do

    it 'can create a team' do
      expect(result['data']['createTeam']['team']['name']).to eq(variables[:name])
    end

    it 'returns no errors' do
      expect(result['data']['createTeam']['errors']).to be_empty
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t create a team' do
      expect(result['data']['createTeam']).to be_nil
    end

    it 'returns a not authorized error for Mutation.createTeam' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createTeam')
    end
  end
end