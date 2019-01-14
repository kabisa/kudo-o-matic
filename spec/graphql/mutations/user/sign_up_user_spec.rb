# frozen_string_literal: true

RSpec.describe Mutations::User::SignIn do
  set_graphql_type

  let(:context) { {} }
  let(:variables) do
    {
      name: 'John Doe',
      email: 'johndoe@example.com',
      password: 'password',
      passwordConfirmation: 'password'
    }
  end

  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { signUpUser(
      credentials: {
        name: "#{variables[:name]}"
        email: "#{variables[:email]}"
        password: "#{variables[:password]}"
        passwordConfirmation: "#{variables[:passwordConfirmation]}"
      }
    ) { authenticateData { user { id } token } errors } })
  end

  describe 'sign up a user succesfully' do
    let(:token) { result['data']['signUpUser']['authenticateData']['token'] }

    it 'returns a valid token' do
      expect(AuthToken.new.verify(token).keys).to eq([:ok])
    end

    it 'token matches user' do
      expect(AuthToken.new.verify(token).dig(:ok, :id)).to eq(User.last.id)
    end

    it 'returns the user' do
      expect(result['data']['signUpUser']['authenticateData']['user']['id'].to_i).to eq(User.last.id)
    end

    it 'returns no errors' do
      expect(result['data']['signUpUser']['errors']).to be_empty
    end
  end

  describe 'sign up validation errors' do
    let(:variables) do
      {
        name: 'John Doe',
        email: 'johndoe@example.com',
        password: 'password',
        passwordConfirmation: 'password1'
      }
    end

    it 'returns an error if some input is not correct' do
      expect(result['data']['signUpUser']['authenticateData']).to be_nil
      expect(result['data']['signUpUser']['errors']).to_not be_empty
    end
  end
end