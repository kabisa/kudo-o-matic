# frozen_string_literal: true

RSpec.describe Mutations::KudosMeter::DeleteKudosMeter do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let!(:kudos_meter) { team.active_kudos_meter }

  let(:variables) { { kudos_meter_id: kudos_meter.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { deleteKudosMeter(
      kudosMeterId: "#{variables[:kudos_meter_id]}"
    ) { kudosMeterId errors } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can delete a kudos meter' do
        expect { result }.to change { team.kudos_meters.count }.by(-1)
        expect(result['data']['deleteKudosMeter']['kudosMeterId'].to_i).to eq(kudos_meter.id)
      end

      it 'returns no errors' do
        expect(result['data']['deleteKudosMeter']['errors']).to be_empty
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can delete a kudos meter' do
        expect { result }.to change { team.kudos_meters.count }.by(-1)
        expect(result['data']['deleteKudosMeter']['kudosMeterId'].to_i).to eq(kudos_meter.id)
      end

      it 'returns no errors' do
        expect(result['data']['deleteKudosMeter']['errors']).to be_empty
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t delete a kudos meter' do
        expect(result['data']['deleteKudosMeter']).to be_nil
      end

      it 'returns a not authorized error for Mutation.deleteKudosMeter' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteKudosMeter')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t delete a kudos meter' do
        expect(result['data']['deleteKudosMeter']).to be_nil
      end

      it 'returns a not authorized error for Mutation.deleteKudosMeter' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteKudosMeter')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t delete a kudos meter' do
      expect(result['data']['deleteKudosMeter']).to be_nil
    end

    it 'returns a not authorized error for Mutation.deleteKudosMeter' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteKudosMeter')
    end
  end
end