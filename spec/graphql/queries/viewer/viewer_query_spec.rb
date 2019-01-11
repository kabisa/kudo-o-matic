# frozen_string_literal: true

RSpec.describe Queries::ViewerQuery do
  set_graphql_type

  it 'subject returns User!' do
    expect(subject.type.to_type_signature).to eq ('User')
  end

  let(:user) { create(:user) }

  let(:variables) { {} }
  let(:result) do
    res = KudoOMaticSchema.execute(
        query_string,
        context: context,
        variables: variables
    )
    res
  end
  let(:query_string) { %({ viewer { id name email avatar admin virtualUser} }) }

  context 'authenticated' do
    let(:context) { { current_user: user } }

    it 'can query the viewer' do
      expect(result['data']['viewer']['id'].to_i).to eq(user.id)
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t query the viewer' do
      expect(result['data']['viewer']).to be_nil
    end

    it 'returns a not authorized error for Query.viewer' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Query.viewer')
    end
  end
end