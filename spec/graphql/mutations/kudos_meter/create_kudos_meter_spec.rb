# frozen_string_literal: true

RSpec.describe Mutations::KudosMeter::CreateKudosMeter do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }

  let(:variables) { { name: 'The kudos meter name', kudos: 5, team_id: team.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
        mutation_string,
        context: context,
        variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { createKudosMeter(
      name: "#{variables[:name]}"
      teamId: "#{variables[:team_id]}"
    ) { kudosMeter { id name team { id } } errors } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can create a kudos meter' do
        expect { result }.to change { team.kudos_meters.count }.by(1)
        expect(result['data']['createKudosMeter']['kudosMeter']['name']).to eq('The kudos meter name')
        expect(result['data']['createKudosMeter']['kudosMeter']['team']['id'].to_i).to eq(team.id)
      end

      it 'returns no errors' do
        expect(result['data']['createKudosMeter']['errors']).to be_empty
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can create a kudos meter' do
        expect { result }.to change { team.kudos_meters.count }.by(1)
        expect(result['data']['createKudosMeter']['kudosMeter']['name']).to eq('The kudos meter name')
        expect(result['data']['createKudosMeter']['kudosMeter']['team']['id'].to_i).to eq(team.id)
      end

      it 'returns no errors' do
        expect(result['data']['createKudosMeter']['errors']).to be_empty
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t create a kudos meter' do
        expect(result['data']['createKudosMeter']).to be_nil
      end

      it 'returns a not authorized error for Mutation.createKudosMeter' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createKudosMeter')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t create a kudos meter' do
        expect(result['data']['createKudosMeter']).to be_nil
      end

      it 'returns a not authorized error for Mutation.createKudosMeter' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createKudosMeter')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t create a kudos meter' do
      expect(result['data']['createKudosMeter']).to be_nil
    end

    it 'returns a not authorized error for Mutation.createKudosMeter' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createKudosMeter')
    end
  end
end