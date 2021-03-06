# frozen_string_literal: true

RSpec.describe Mutations::Guideline::CreateGuideline do
  set_graphql_type

  let(:user) { create(:user) }
  let(:team) { create(:team) }

  let(:variables) { { name: 'The guideline name', kudos: 5, team_id: team.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { createGuideline(
      name: "#{variables[:name]}"
      kudos: #{variables[:kudos]}
      teamId: "#{variables[:team_id]}"
    ) { guideline { id kudos team { id } } } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can create a guideline' do
        expect { result }.to change { team.guidelines.count }.by(1)
        expect(result['data']['createGuideline']['guideline']['kudos']).to eq(5)
        expect(result['data']['createGuideline']['guideline']['team']['id'].to_i).to eq(team.id)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can create a guideline' do
        expect { result }.to change { team.guidelines.count }.by(1)
        expect(result['data']['createGuideline']['guideline']['kudos']).to eq(5)
        expect(result['data']['createGuideline']['guideline']['team']['id'].to_i).to eq(team.id)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t create a guideline' do
        expect(result['data']['createGuideline']).to be_nil
      end

      it 'returns a not authorized error for Mutation.createGuideline' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createGuideline')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t create a guideline' do
        expect(result['data']['createGuideline']).to be_nil
      end

      it 'returns a not authorized error for Mutation.createGuideline' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createGuideline')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t create a guideline' do
      expect(result['data']['createGuideline']).to be_nil
    end

    it 'returns a not authorized error for Mutation.createGuideline' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createGuideline')
    end
  end
end