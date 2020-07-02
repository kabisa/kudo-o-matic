require 'sidekiq/testing'
Sidekiq::Testing.fake!

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

  describe 'user auth callback' do
    it 'Redirects to the correct url if the request is successful' do
      allow(Slack::SlackService).to receive(:connect_account).and_return(true)
      payload = {
          token: 'fakeToken'
      }

      get '/auth/callback/slack/user/1', :params => payload

      expect(response.status).to be(302)
      expect(response).to redirect_to(Settings.slack_user_connect_success_url)
    end

    it 'returns an error if the request fails' do
      allow(Slack::SlackService).to receive(:connect_account).and_raise(Slack::SlackService::InvalidRequest, 'The error description')
      payload = {
          token: 'fakeToken'
      }

      get '/auth/callback/slack/user/1', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, The error description")
    end
  end

  describe 'team auth callback' do
    it 'Redirects to the correct url if the request is successful' do
      allow(Slack::SlackService).to receive(:add_to_workspace).and_return(true)
      payload = {
          token: 'fakeToken'
      }

      get '/auth/callback/slack/team/1', :params => payload

      expect(response.status).to be(302)
      expect(response).to redirect_to(Settings.slack_team_connect_success_url)
    end

    it 'returns an error if the request fails' do
      allow(Slack::SlackService).to receive(:add_to_workspace).and_raise(Slack::SlackService::InvalidRequest, 'The error description')
      payload = {
          token: 'fakeToken'
      }

      get '/auth/callback/slack/team/1', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, The error description")
    end
  end

  describe 'give kudos' do
    it 'calls the slacks service to create a post' do
      allow(Slack::SlackService).to receive(:create_post)
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

    it "returns an error if there was one" do
      allow(Slack::SlackService).to receive(:create_post).and_raise(Slack::SlackService::InvalidCommand.new('Some error'))
      payload = {
          text: 'commandText',
          user_id: 'UU1234',
          team_id: 'UU4321'
      }

      post '/slack/kudo', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq("That didn't quite work, Some error \n The format is: /kudo @someone @someone.else [amount] for [reason]")
    end

  end

  describe 'guidelines' do
    it 'returns when there is an error' do
      allow(Slack::SlackService).to receive(:list_guidelines).and_raise(Slack::SlackService::InvalidCommand, 'Error description')
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
      allow(Slack::SlackService).to receive(:list_guidelines).and_return(return_value)
      payload = {
          team_id: 'UU4321'
      }

      post '/slack/guidelines', :params => payload

      expect(response.status).to be(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['blocks']).to_not be_nil

    end
  end

  describe 'auth team' do
    it 'redirect to different url' do
      get '/auth/slack/team/1'

      expect(response.status).to be(302)
    end
  end

  describe 'auth user' do
    it 'redirect to different url' do
      get '/auth/slack/user/1'

      expect(response.status).to be(302)
    end
  end

  describe 'event' do
    describe 'url verification' do
      it 'responds with the challenge parameter' do
        payload = {
            type: 'url_verification',
            challenge: 'challenge_token'
        }

        post '/slack/event', :params => payload

        expect(response.status).to be(200)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['challenge']).to eq('challenge_token')
      end
    end

    describe 'event callback' do
      it 'starts a new sidekiq job' do
        payload = {
            type: 'event_callback',
            event: {
                type: 'reaction_added'
            }
        }

        expect {
          post '/slack/event', :params => payload
        }.to change(SlackWorker.jobs, :size).by(1)
      end

      it 'returns 200 OK' do
        payload = {
            type: 'event_callback',
            event: {
                type: 'reaction_added'
            }
        }

        post '/slack/event', :params => payload

        expect(response.status).to be(200)
      end
    end
  end
end

