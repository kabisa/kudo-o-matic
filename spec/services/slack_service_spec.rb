class DummyClass
  include SlackService
end

RSpec.describe 'SlackService' do
  let(:team) { create(:team) }
  let(:team_with_slack) { create(:team, :with_slack) }
  let(:user) { create(:user) }
  let(:user_with_slack_id) { create(:user, :with_slack_id) }
  let(:dc) { DummyClass.new }

  def create_add_post_command(receivers, message, amount)
    command = ""
    receivers.each { |user| command += "<@#{user.slack_id}|#{user.name}>" }
    return command += "'#{message}' #{amount}"
  end

  before :each do
    team.add_member(user)
    team.add_member(user_with_slack_id)
  end

  describe 'add to workspace' do
    it 'updates the team channel id, access token and slack id' do
      mock_response = {
          :incoming_webhook => {
              :channel_id => 'channelId'
          },
          :access_token => 'accessToken',
          :team => {
              :id => 'teamId'
          }
      }

      response = double('response', :body => mock_response.to_json.to_s)
      allow(RestClient).to receive(:post).and_return(response)

      expect {
        dc.add_to_workspace('token', team.id)
        team.reload
      }.to change(team, :channel_id).from(nil).to('channelId')
               .and change(team, :slack_bot_access_token).from(nil).to('accessToken')
                        .and change(team, :slack_team_id).from(nil).to('teamId')
    end

    it 'returns an error if there is no token' do
      expect { dc.add_to_workspace(nil, team.id) }.to raise_exception(SlackService::InvalidRequest)
    end

    it 'returns an error if there is no team id' do
      expect { dc.add_to_workspace('token', nil) }.to raise_exception(SlackService::InvalidRequest)
    end
  end

  describe 'connect account' do
    it 'updates the slack id and registration token' do
      expect {
        dc.connect_account(user.slack_registration_token, 'slackId')
        user.reload
      }.to change(user, :slack_id).from(nil).to('slackId')
               .and change(user, :slack_registration_token).from(user.slack_registration_token).to(nil)
    end

    it 'raises an error if there is no token' do
      expect {
        dc.connect_account('', 'slackId')
      }.to raise_exception(SlackService::InvalidCommand, 'please provide a register token')
    end

    it 'raises an error if the slack id is already connected to a user' do
      expect {
        dc.connect_account(user.slack_registration_token,
                           user_with_slack_id.slack_id)
      }.to raise_exception(SlackService::InvalidCommand, 'This slack account is already linked to kudo-o-matic')
    end

    it 'returns an error if there is no user for the provided registration token' do
      expect {
        dc.connect_account('invalidRegisterToken',
                           'slackId')
      }.to raise_exception(SlackService::InvalidCommand, 'Invalid registration token')
    end

    it 'returns an error if the user is already connected to slack' do
      expect {
        dc.connect_account(user_with_slack_id.slack_registration_token,
                           'otherSlackId')
      }.to raise_exception(SlackService::InvalidCommand, 'This kudo-o-matic account is already linked to Slack.')
    end
  end

  describe 'send post announcement' do
    it 'has the correct message' do
      post = create(:post, sender: user, receivers: [user_with_slack_id], team: team, kudos_meter: team.active_kudos_meter)

      payload = {
          text: "#{user.name} just gave #{post.amount} kudos to <@#{user_with_slack_id.slack_id}> for #{post.message}",
          token: anything,
          channel: anything
      }

      expect(RestClient).to receive(:post).with(anything, payload)
      dc.send_post_announcement(post)
    end

    it 'uses the correct token' do
      team.slack_bot_access_token = 'accessToken'
      post = create(:post, sender: user, receivers: [user_with_slack_id], team: team, kudos_meter: team.active_kudos_meter)

      payload = {
          text: anything,
          token: 'accessToken',
          channel: anything
      }

      expect(RestClient).to receive(:post).with(anything, payload)
      dc.send_post_announcement(post)
    end

    it 'posts to the correct channel' do
      team.channel_id = 'slackChannelId'
      post = create(:post, sender: user, receivers: [user_with_slack_id], team: team, kudos_meter: team.active_kudos_meter)

      payload = {
          text: anything,
          token: anything,
          channel: 'slackChannelId'
      }

      expect(RestClient).to receive(:post).with(anything, payload)
      dc.send_post_announcement(post)
    end

    it 'posts to the correct url' do
      post = create(:post, sender: user, receivers: [user_with_slack_id], team: team, kudos_meter: team.active_kudos_meter)

      expect(RestClient).to receive(:post).with('fakeUrl', anything)
      dc.send_post_announcement(post)
    end
  end

  describe 'create post' do
    describe 'receivers' do
      it 'returns an error if one or more receivers are not connected to slack' do
        command = create_add_post_command([user], 'message', 10)

        expect {
          dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.id)
        }.to raise_exception(SlackService::InvalidCommand, "#{user.name} has not connected their account to Slack.")
      end

      it 'returns an error if there are no receivers' do
        command = create_add_post_command([], 'message', 10)

        expect {
          dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.id)
        }.to raise_exception(SlackService::InvalidCommand, "Did you forget to mention any users with the '@' symbol?")
      end

      it 'gets all the receivers' do
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.receivers[0].id).to be(user_with_slack_id.id)
      end
    end

    describe 'message' do
      it 'returns an error if there is no message included' do
        command = create_add_post_command([user_with_slack_id], '', 10)

        expect {
          dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.id)
        }.to raise_exception(SlackService::InvalidCommand, "Did you include a message surrounded by '?")
      end

      it 'sets the message correctly' do
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.message).to eq('message')
      end
    end

    describe 'amount' do
      it 'returns an error if there is no amount' do
        command = create_add_post_command([user_with_slack_id], 'message', nil)

        expect {
          dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.id)
        }.to raise_exception(SlackService::InvalidCommand, "Did you include an amount?")
      end

      it 'returns an error if the amount is not a valid integer' do
        command = create_add_post_command([user_with_slack_id], 'message', 'ImNotANumber')

        expect {
          dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.id)
        }.to raise_exception(SlackService::InvalidCommand, "Did you include an amount?")
      end

      it 'sets the amount correctly' do
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.amount).to eq(10)
      end
    end

    describe 'team' do
      it 'returns an error if there is no team for the provided slack id' do
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        expect {
          dc.create_post(command, 'wrongSlackId', user_with_slack_id.id)
        }.to raise_exception(SlackService::InvalidCommand, "This workspace does not have an associated Kudo-o-matic team, contact an admin")
      end

      it 'sets the team correctly' do
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.team.id).to be(team_with_slack.id)
      end
    end

    describe 'sender' do
      it 'returns an error if the sender is not connected to Slack' do
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        expect {
          dc.create_post(command, team_with_slack.slack_team_id, 'UnusedSlackId')
        }.to raise_exception(SlackService::InvalidCommand, "Your Slack account is not linked to Kudo-o-matic, use the /register command")
      end

      it 'sets the sender correctly' do
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = dc.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.sender.id).to be(user_with_slack_id.id)
      end
    end
  end

  describe 'list guidelines' do
    let(:guideline) {create(:guideline)}

    it 'raises en error when there is no team with the provided slack id' do
      expect {
        dc.list_guidelines('unusedId')
      }.to raise_exception(SlackService::InvalidCommand, 'No team with that Slack ID')
    end

    it 'returns a message when there are no guidelines' do
      response = dc.list_guidelines(team_with_slack.slack_team_id)

      expect(response.length).to be(1)
      expect(response[0][:text][:text]).to eq('No guidelines')
    end

    it 'returns the guidelines as a section' do
      guideline.team = team_with_slack
      guideline.save

      response = dc.list_guidelines(team_with_slack.slack_team_id)

      expect(response.length).to be(1)
      expect(response[0][:text][:text]).to eq("• #{guideline.name} *#{guideline.kudos}* \n")
    end
  end
end