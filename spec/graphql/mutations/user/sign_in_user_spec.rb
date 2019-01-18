# frozen_string_literal: true

RSpec.describe Mutations::User::SignIn do
  set_graphql_type

  let!(:user) { create(:user) }
  let(:context) { {} }
  let(:variables) do
    {
      email: user.email,
      password: 'password'
    }
  end

  let(:result) do
    res = KudoOMaticSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:query_string) do
    %( mutation { signInUser(
      credentials: {
        email: "#{variables[:email]}"
        password: "#{variables[:password]}"
      }
    ) { authenticateData { user { id } token } errors } })
  end

  describe 'sign in a user successfully' do
    let(:token) { result['data']['signInUser']['authenticateData']['token'] }

    it 'returns a valid token' do
      expect(AuthToken.new.verify(token).keys).to eq([:ok])
    end

    it 'token matches user' do
      expect(AuthToken.new.verify(token).dig(:ok, :id)).to eq(user.id)
    end

    it 'returns the user' do
      expect(result['data']['signInUser']['authenticateData']['user']['id'].to_i).to eq(user.id)
    end

    it 'returns no errors' do
      expect(result['data']['signInUser']['errors']).to be_empty
    end
  end

  describe 'sign in validation errors' do
    let(:variables) do
      {
        email: user.email,
        password: 'wrongpassword'
      }
    end

    it 'returns an error if some input is not correct' do
      expect(result['data']['signInUser']['authenticateData']).to be_nil
      expect(result['data']['signInUser']['errors']).to_not be_empty
    end
  end
end