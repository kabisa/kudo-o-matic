RSpec.describe Mutations::KudosMeter::SetActiveKudosMeter do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let(:new_kudos_meter) { create(:kudos_meter, team_id: team.id) }

  let(:variables) { {new_kudos_meter_id: new_kudos_meter.id, team_id: team.id} }
  let(:result) do
    res = KudoOMaticSchema.execute(
        mutation_string,
        context: context,
        variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { setActiveKudosMeter(
      kudosMeterId: "#{variables[:new_kudos_meter_id]}"
      teamId: "#{variables[:team_id]}"
    ) { kudosMeter { id isActive team { id } } } } )
  end

  context 'authenticated' do
    let(:context) { {current_user: user} }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can set the active kudos meter' do
        expect(result['data']['setActiveKudosMeter']['kudosMeter']['isActive']).to be(true)
        expect(result['data']['setActiveKudosMeter']['kudosMeter']['team']['id'].to_i).to eq(team.id)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can update a kudos meter' do
        expect(result['data']['setActiveKudosMeter']['kudosMeter']['isActive']).to be(true)
        expect(result['data']['setActiveKudosMeter']['kudosMeter']['team']['id'].to_i).to eq(team.id)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end
    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t set the active kudos meter' do
        expect(result['data']['setActiveKudosMeter']).to be_nil
      end

      it 'returns a not authorized error for Mutation.setActiveKudosMeter' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.setActiveKudosMeter')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t set the active kudos meter' do
        expect(result['data']['setActiveKudosMeter']).to be_nil
      end

      it 'returns a not authorized error for Mutation.setActiveKudosMeter' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.setActiveKudosMeter')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t set the active kudos meter' do
      expect(result['data']['setActiveKudosMeter']).to be_nil
    end

    it 'returns a not authorized error for Mutation.setActiveKudosMeter' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.setActiveKudosMeter')
    end
  end
end
