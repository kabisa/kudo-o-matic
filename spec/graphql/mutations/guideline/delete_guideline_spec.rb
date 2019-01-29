# frozen_string_literal: true

RSpec.describe Mutations::Guideline::DeleteGuideline do
  set_graphql_type

  let!(:user) { create(:user) }
  let!(:team) { create(:team) }
  let!(:guidelines) { create_list(:guideline, 5, team: team) }

  let(:variables) { { guideline_id: guidelines.first.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { deleteGuideline(
      guidelineId: "#{variables[:guideline_id]}"
    ) { guidelineId errors } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can delete a guideline' do
        expect { result }.to change { team.guidelines.count }.by(-1)
        expect(result['data']['deleteGuideline']['guidelineId'].to_i).to eq(guidelines.first.id)
      end

      it 'returns no errors' do
        expect(result['data']['deleteGuideline']['errors']).to be_empty
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      it 'can delete a guideline' do
        expect { result }.to change { team.guidelines.count }.by(-1)
        expect(result['data']['deleteGuideline']['guidelineId'].to_i).to eq(guidelines.first.id)
      end

      it 'returns no errors' do
        expect(result['data']['deleteGuideline']['errors']).to be_empty
      end

    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can\'t delete a guideline' do
        expect(result['data']['deleteGuideline']).to be_nil
      end

      it 'returns a not authorized error for Mutation.deleteGuideline' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteGuideline')
      end
    end

    describe 'user is not a team member' do
      it 'can\'t delete a guideline' do
        expect(result['data']['deleteGuideline']).to be_nil
      end

      it 'returns a not authorized error for Mutation.deleteGuideline' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteGuideline')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t delete a guideline' do
      expect(result['data']['deleteGuideline']).to be_nil
    end

    it 'returns a not authorized error for Mutation.deleteGuideline' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deleteGuideline')
    end
  end
end