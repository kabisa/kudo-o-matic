# frozen_string_literal: true

RSpec.describe Mutations::Goal::CreateGoal do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:goals) { kudos_meter.goals }

  let(:variables) { { name: 'The new goal name', amount: 1000, goal_id: goals.first.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { updateGoal(
      name: "#{variables[:name]}"
      amount: #{variables[:amount]}
      goalId: "#{variables[:goal_id]}"
    ) { goal { id name amount kudosMeter { id } } } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can update a goal' do
        expect(result['data']['updateGoal']['goal']['id'].to_i).to eq(variables[:goal_id])
        expect(result['data']['updateGoal']['goal']['name']).to eq('The new goal name')
        expect(result['data']['updateGoal']['goal']['amount']).to eq(variables[:amount])
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can update a goal' do
        expect(result['data']['updateGoal']['goal']['id'].to_i).to eq(variables[:goal_id])
        expect(result['data']['updateGoal']['goal']['name']).to eq('The new goal name')
        expect(result['data']['updateGoal']['goal']['amount']).to eq(variables[:amount])
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t update a goal' do
        expect(result['data']['updateGoal']).to be_nil
      end

      it 'returns a not authorized error for Mutation.updateGoal' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateGoal')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t update a goal' do
        expect(result['data']['updateGoal']).to be_nil
      end

      it 'returns a not authorized error for Mutation.updateGoal' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateGoal')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t update a goal' do
      expect(result['data']['updateGoal']).to be_nil
    end

    it 'returns a not authorized error for Mutation.updateGoal' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateGoal')
    end
  end
end