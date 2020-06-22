# frozen_string_literal: true

RSpec.describe Mutations::Guideline::UpdateGuideline do
  set_graphql_type

  let!(:user) { create(:user) }
  let!(:team) { create(:team) }
  let!(:guidelines) { create_list(:guideline, 5, team: team) }

  let(:variables) { { guideline_id: guidelines.first.id, name: 'The new name', kudos: 250 } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { updateGuideline(
      guidelineId: "#{variables[:guideline_id]}"
      name: "#{variables[:name]}"
      kudos: #{variables[:kudos]}
    ) { guideline { name kudos } } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can update a guideline' do
        expect(result['data']['updateGuideline']['guideline']['name']).to eq(variables[:name])
        expect(result['data']['updateGuideline']['guideline']['kudos']).to eq(variables[:kudos])
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can update a guideline' do
        expect(result['data']['updateGuideline']['guideline']['name']).to eq(variables[:name])
        expect(result['data']['updateGuideline']['guideline']['kudos']).to eq(variables[:kudos])
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t update a guideline' do
        expect(result['data']['updateGuideline']).to be_nil
      end

      it 'returns a not authorized error for Mutation.updateGuideline' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateGuideline')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t update a guideline' do
        expect(result['data']['updateGuideline']).to be_nil
      end

      it 'returns a not authorized error for Mutation.updateGuideline' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateGuideline')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t delete a post' do
      expect(result['data']['updateGuideline']).to be_nil
    end

    it 'returns a not authorized error for Mutation.updateGuideline' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.updateGuideline')
    end
  end
end