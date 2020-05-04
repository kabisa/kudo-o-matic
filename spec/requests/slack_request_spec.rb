RSpec.describe "Slack" do
  let(:user) { create(:user) }
  let!(:users) { create_list(:user, 1) }
  let(:userWithSlackId) { create(:user, :with_slack_id) }
  let(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }

  before do
    team.add_member(user)
    users.each { |user| team.add_member(user) }
  end

  describe 'register' do
    it 'connects the kudo-o-matic account to Slack' do
      payload = {
          text: user.slack_registration_token,
          user_id: 'fakeSlackId'
      }

      post '/slack/register', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq('Account successfully linked!')
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
    it 'Redirects to the correct url if the request is successful' do
      allow(SlackService).to receive(:add_to_workspace).and_return(true)
      payload = {
          token: 'fakeToken',
          state: '1'
      }

      get '/auth/callback/slack', :params => payload

      expect(response.status).to be(302)
      expect(response).to redirect_to(Settings.slack_connect_success_url)
    end

    it 'returns an error if the request fails' do
      allow(SlackService).to receive(:add_to_workspace).and_raise(SlackService::InvalidRequest, 'The error description')
      payload = {
          token: 'fakeToken',
          state: '1'
      }

      get '/auth/callback/slack', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, The error description")
    end
  end

  describe 'give_kudos' do
    it 'Creates a post and sends an announcement' do
      allow_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
      post = create(:post, sender: user, receivers: [users.first], team: team, kudos_meter: kudos_meter)
      allow(SlackService).to receive(:create_post).and_return(post)
      payload = {
          text: 'commandText',
          user_id: 'UU1234',
          team_id: 'UU4321'
      }

      post '/slack/kudo', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq('kudos are on the way!')
    end

    it "returns an error if the post isn't valid" do
      post = create(:post, sender: user, receivers: [users.first], team: team, kudos_meter: kudos_meter)
      allow(SlackService).to receive(:create_post).and_return(post)
      post.receivers = []
      payload = {
          text: 'commandText',
          user_id: 'UU1234',
          team_id: 'UU4321'
      }

      post '/slack/kudo', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, Receivers can't be blank")
    end

    it "returns an error if the post isn't valid" do
      allow(SlackService).to receive(:create_post).and_raise(SlackService::InvalidCommand, 'Error description')
      payload = {
          text: 'commandText',
          user_id: 'UU1234',
          team_id: 'UU4321'
      }

      post '/slack/kudo', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, Error description")
    end
  end

  describe 'guidelines' do
    it 'returns when there is an error' do
      allow(SlackService).to receive(:list_guidelines).and_raise(SlackService::InvalidCommand, 'Error description')
      payload = {
          team_id: 'UU4321'
      }

      post '/slack/guidelines', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, Error description")
    end

    it 'return the guidelines as a block' do
      return_value = {
          type: "section",
      }
      allow(SlackService).to receive(:list_guidelines).and_return(return_value)
      payload = {
          team_id: 'UU4321'
      }

      post '/slack/guidelines', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['blocks']).to_not be_nil

    end
  end
end

