# frozen_string_literal: true

RSpec.describe Mutations::KudosMeter::UpdateKudosMeter do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let!(:kudos_meter) { team.active_kudos_meter }

  let(:variables) { { name: 'The kudos meter name updated', kudos_meter_id: kudos_meter.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { updateKudosMeter(
      name: "#{variables[:name]}"
      kudosMeterId: "#{variables[:kudos_meter_id]}"
    ) { kudosMeter { id name team { id } } errors } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can update a kudos meter' do
        expect(result['data']['updateKudosMeter']['kudosMeter']['name']).to eq('The kudos meter name updated')
        expect(result['data']['updateKudosMeter']['kudosMeter']['team']['id'].to_i).to eq(team.id)
      end

      it 'returns no errors' do
        expect(result['data']['updateKudosMeter']['errors']).to be_empty
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can update a kudos meter' do
        expect(result['data']['updateKudosMeter']['kudosMeter']['name']).to eq('The kudos meter name updated')
        expect(result['data']['updateKudosMeter']['kudosMeter']['team']['id'].to_i).to eq(team.id)
      end

      it 'returns no errors' do
        expect(result['data']['updateKudosMeter']['errors']).to be_empty
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t update a kudos meter' do
        expect(result['data']['updateKudosMeter']).to be_nil
      end

      it 'returns a not authorized error for Mutation.updateKudosMeter' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateKudosMeter')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t update a kudos meter' do
        expect(result['data']['updateKudosMeter']).to be_nil
      end

      it 'returns a not authorized error for Mutation.updateKudosMeter' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateKudosMeter')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t update a kudos meter' do
      expect(result['data']['updateKudosMeter']).to be_nil
    end

    it 'returns a not authorized error for Mutation.updateKudosMeter' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateKudosMeter')
    end
  end
end