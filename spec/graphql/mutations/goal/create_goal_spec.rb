# frozen_string_literal: true

RSpec.describe Mutations::Goal::CreateGoal do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }

  let(:variables) { { name: 'The goal name', amount: 1000, kudos_meter_id: kudos_meter.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { createGoal(
      name: "#{variables[:name]}"
      amount: #{variables[:amount]}
      kudosMeterId: "#{variables[:kudos_meter_id]}"
    ) { goal { id amount kudosMeter { id } } errors } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can create a goal' do
        expect { result }.to change { team.goals.count }.by(1)
        expect(result['data']['createGoal']['goal']['amount']).to eq(variables[:amount])
        expect(result['data']['createGoal']['goal']['kudosMeter']['id'].to_i).to eq(kudos_meter.id)
      end

      it 'returns no errors' do
        expect(result['data']['createGoal']['errors']).to be_empty
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can create a goal' do
        expect { result }.to change { team.goals.count }.by(1)
        expect(result['data']['createGoal']['goal']['amount']).to eq(variables[:amount])
        expect(result['data']['createGoal']['goal']['kudosMeter']['id'].to_i).to eq(kudos_meter.id)
      end

      it 'returns no errors' do
        expect(result['data']['createGoal']['errors']).to be_empty
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t create a goal' do
        expect(result['data']['createGoal']).to be_nil
      end

      it 'returns a not authorized error for Mutation.createGoal' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createGoal')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t create a goal' do
        expect(result['data']['createGoal']).to be_nil
      end

      it 'returns a not authorized error for Mutation.createGoal' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createGoal')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t create a goal' do
      expect(result['data']['createGoal']).to be_nil
    end

    it 'returns a not authorized error for Mutation.createGoal' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createGoal')
    end
  end
end