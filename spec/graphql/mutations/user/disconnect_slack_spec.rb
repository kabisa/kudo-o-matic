RSpec.describe Mutations::User::DisconnectSlack do
  set_graphql_type

  let!(:user) { create(:user, :with_slack_id, :with_slack_access_token) }
  let!(:user_without_slack) { create(:user) }
  let(:context) { {current_user: user} }

  let(:result) do
    res = KudoOMaticSchema.execute(
        mutation_string,
        context: context
    )
    res
  end

  let(:mutation_string) do
    %( mutation { disconnectSlack { user { id } } } )
  end

  context 'authenticated' do
    describe 'user connected to slack' do
      it 'removes the slack id and slack access token' do
        expect {
          result
        }.to change { user.slack_id }.to(nil)
                 .and change { user.slack_access_token }.to(nil)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user not connected to slack' do
      before do
        context = user_without_slack
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t reset password' do
      expect(result['data']['disconnectSlack']).to be_nil
    end

    it 'returns a not authorized error for Mutation.disconnectSlack' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.disconnectSlack')
    end
  end
end

