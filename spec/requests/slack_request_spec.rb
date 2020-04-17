RSpec.describe "GraphQL" do
  let(:user) { create(:user) }
  let(:userWithSlackId) { create(:user, :withSlackId) }

  describe 'register' do
    it 'stores the slack id for the correct user' do
      payload = {
          text: user.slack_registration_token,
          user_id: 'fakeSlackId'
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq('Account successfully linked!')
      expect(User.find(user.id).slack_id).to eq('fakeSlackId')
    end

    it 'returns an error if no token is provided' do
      payload = {
          text: '',
          user_id: 'fakeSlackId'
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, please provide a register token")
    end

    it 'returns an error if no user id is provided' do
      payload = {
          text: 'token',
          user_id: ''
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, Invalid registration token")
    end

    it 'returns an error if the token is invalid' do
      payload = {
          text: 'fakeToken',
          user_id: 'fakeSlackId'
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, Invalid registration token")
    end

    it 'returns an error if the user is already connected to slack' do
      payload = {
          text: user.slack_registration_token,
          user_id: userWithSlackId.slack_id
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, This slack account is already linked to kudo-o-matic")
    end
  end

  describe 'auth_callback' do
    it 'stores the information for the correct team' do
      payload = {
          text: user.slack_registration_token,
          user_id: 'fakeSlackId'
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq('Account successfully linked!')
      expect(User.find(user.id).slack_id).to eq('fakeSlackId')
    end

    it 'returns an error if no token is provided' do
      payload = {
          text: '',
          user_id: 'fakeSlackId'
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, please provide a register token")
    end

    it 'returns an error if no user id is provided' do
      payload = {
          text: 'token',
          user_id: ''
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, Invalid registration token")
    end

    it 'returns an error if the token is invalid' do
      payload = {
          text: 'fakeToken',
          user_id: 'fakeSlackId'
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, Invalid registration token")
    end

    it 'returns an error if the user is already connected to slack' do
      payload = {
          text: user.slack_registration_token,
          user_id: userWithSlackId.slack_id
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, This slack account is already linked to kudo-o-matic")
    end
  end
end

