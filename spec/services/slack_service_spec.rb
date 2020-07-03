RSpec.describe 'SlackService' do
  let(:team) { create(:team) }
  let(:team_with_slack) { create(:team, :with_slack) }
  let(:user) { create(:user) }
  let(:user_with_slack_id) { create(:user, :with_slack_id) }
  let(:post) { create(:post, sender: user, receivers: [user_with_slack_id], team: team, kudos_meter: team.active_kudos_meter) }
  let(:first_goal) { create(:goal) }
  let(:second_goal) { create(:goal) }

  def create_add_post_command(receivers, message, amount)
    command = receivers.map { |user| "<@#{user.slack_id}|#{user.name}>" }
    command.push("#{amount} for #{message}")
    command.join(' ')
  end

  before :each do
    team.add_member(user)
    team.add_member(user_with_slack_id)

    team_with_slack.add_member(user)
    team_with_slack.add_member(user_with_slack_id)
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

      allow_any_instance_of(Slack::Web::Client).to receive(:oauth_v2_access).and_return(mock_response.as_json)
      Slack::SlackService.should_receive(:send_welcome_message)
      Slack::SlackService.should_receive(:join_all_channels)

      expect {
        Slack::SlackService.add_to_workspace('token', team.id)
        team.reload
      }.to change(team, :channel_id).from(nil).to('channelId')
               .and change(team, :slack_bot_access_token).from(nil).to('accessToken')
                        .and change(team, :slack_team_id).from(nil).to('teamId')
    end

    it 'returns an error if there is no token' do
      expect { Slack::SlackService.add_to_workspace(nil, team.id) }.to raise_exception(Slack::Exceptions::InvalidRequest)
    end

    it 'returns an error if there is no team id' do
      expect { Slack::SlackService.add_to_workspace('token', nil) }.to raise_exception(Slack::Exceptions::InvalidRequest)
    end
  end

  describe 'connect account' do
    before do
      mock_response = {
          authed_user: {
              access_token: 'accessToken',
              id: 'someSlackId'
          }
      }

      allow_any_instance_of(Slack::Web::Client).to receive(:oauth_v2_access).and_return(mock_response.as_json)
    end

    it 'updates the slack id and access token' do

      expect {
        Slack::SlackService.connect_account('token', user.id)
        user.reload
      }.to change(user, :slack_id).from(nil).to('someSlackId')
               .and change(user, :slack_access_token).from(nil).to('accessToken')
    end

    it 'raises an error if there is no token' do
      expect {
        Slack::SlackService.connect_account(nil, 'slackId')
      }.to raise_exception(Slack::Exceptions::InvalidCommand, 'Missing auth token')
    end

    it 'raises an error if there is no user id' do
      expect {
        Slack::SlackService.connect_account('code', nil)
      }.to raise_exception(Slack::Exceptions::InvalidCommand, 'Missing user id')
    end

    it 'raises an error if the slack id is already connected to a user' do
      mock_response = {
          authed_user: {
              access_token: 'accessToken',
              id: 'fakeSlackId'
          }
      }

      allow_any_instance_of(Slack::Web::Client).to receive(:oauth_v2_access).and_return(mock_response.as_json)

      expect {
        Slack::SlackService.connect_account('code', user.id)
      }.to raise_exception(Slack::Exceptions::InvalidCommand, 'This Slack account is already linked to Kudo-O-Matic')
    end

    it 'returns an error if the user is already connected to slack' do
      expect {
        Slack::SlackService.connect_account('token', user_with_slack_id.id)
      }.to raise_exception(Slack::Exceptions::InvalidCommand, 'This Kudo-O-Matic account is already linked to Slack')
    end
  end

  describe 'send post announcement' do
    it 'has the correct message' do
      post = create(:post, sender: user, receivers: [user_with_slack_id], team: team, kudos_meter: team.active_kudos_meter)

      message = "#{user.name} just gave #{post.amount} kudos to <@#{user_with_slack_id.slack_id}> for #{post.message}"
      blocks = [
          {
              type: 'section',
              text: {
                  type: 'mrkdwn',
                  text: message
              }
          },
          {
              type: 'context',
              block_id: post.id.to_s,
              elements: [
                  type: 'mrkdwn',
                  text: '_This message is a Kudo-O-Matic post_'
              ]
          }
      ]

      expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).with(channel: nil, blocks: blocks)
      Slack::SlackService.send_post_announcement(post)
    end

    it 'posts to the correct channel' do
      team.channel_id = 'slackChannelId'
      post = create(:post, sender: user, receivers: [user_with_slack_id], team: team, kudos_meter: team.active_kudos_meter)

      expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).with(channel: 'slackChannelId', blocks: anything)
      Slack::SlackService.send_post_announcement(post)
    end
  end

  describe 'send goal announcement' do
    before do
      first_goal.kudos_meter = team_with_slack.active_kudos_meter

      second_goal.name = 'second goal'
      second_goal.amount = 700

    end

    it 'has the correct message' do
      blocks = [
          {
              type: 'section',
              text: {
                  type: 'mrkdwn',
                  text: ":tada: We've just reached goal '#{first_goal.name}' at #{first_goal.amount} Kudos :tada:"
              }
          },
          {
              type: 'section',
              text: {
                  type: 'mrkdwn',
                  text: "Our next goal is '#{second_goal.name}' at #{second_goal.amount} Kudos, so keep the Kudos coming and we'll be there in no time! :muscle:"
              }
          }
      ]

      expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).with(channel: anything, blocks: blocks)
      Slack::SlackService.send_goal_announcement(first_goal, second_goal)
    end

    it 'posts to the correct channel' do
      expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).with(channel: team_with_slack.channel_id, blocks: anything)
      Slack::SlackService.send_goal_announcement(first_goal, second_goal)
    end
  end

  describe 'create post' do
    describe 'receivers' do
      it 'returns an error if one or more receivers are not connected to slack' do
        command = create_add_post_command([user], 'message', 10)

        expect {
          Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        }.to raise_exception(Slack::Exceptions::InvalidCommand, "#{user.name} has not connected their account to Slack.")
      end

      it 'returns an error if there are no receivers' do
        command = create_add_post_command([], 'message', 10)

        expect {
          Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        }.to raise_exception(Slack::Exceptions::InvalidCommand, "Did you forget to mention any users with the '@' symbol?")
      end

      it 'gets all the receivers' do
        allow(Slack::SlackService).to receive(:send_post_announcement)
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.receivers[0].id).to be(user_with_slack_id.id)
      end
    end

    describe 'message' do
      it 'returns an error if there is no message included' do
        command = create_add_post_command([user_with_slack_id], '', 10)

        expect {
          Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        }.to raise_exception(Slack::Exceptions::InvalidCommand, "Did you include a message?")
      end

      it 'sets the message correctly' do
        allow(Slack::SlackService).to receive(:send_post_announcement)
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.message).to eq('message')
      end
    end

    describe 'amount' do
      it 'returns an error if there is no amount' do
        command = create_add_post_command([user_with_slack_id], 'message', nil)

        expect {
          Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        }.to raise_exception(Slack::Exceptions::InvalidCommand, "Did you include an amount?")
      end

      it 'returns an error if the amount is not a valid integer' do
        command = create_add_post_command([user_with_slack_id], 'message', 'ImNotANumber')

        expect {
          Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        }.to raise_exception(Slack::Exceptions::InvalidCommand, "Did you include an amount?")
      end

      it 'sets the amount correctly' do
        allow(Slack::SlackService).to receive(:send_post_announcement)
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.amount).to eq(10)
      end
    end

    describe 'team' do
      it 'returns an error if there is no team for the provided slack id' do
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        expect {
          Slack::SlackService.create_post(command, 'wrongSlackId', user_with_slack_id.slack_id)
        }.to raise_exception(Slack::Exceptions::InvalidCommand, "This workspace does not have an associated Kudo-o-matic team, contact an admin")
      end

      it 'sets the team correctly' do
        allow(Slack::SlackService).to receive(:send_post_announcement)
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.team.id).to be(team_with_slack.id)
      end
    end

    describe 'sender' do
      it 'returns an error if the sender is not connected to Slack' do
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        expect {
          Slack::SlackService.create_post(command, team_with_slack.slack_team_id, 'UnusedSlackId')
        }.to raise_exception(Slack::Exceptions::InvalidCommand, "No Kudo-o-matic user found with that Slack ID")
      end

      it 'sets the sender correctly' do
        allow(Slack::SlackService).to receive(:send_post_announcement)
        command = create_add_post_command([user_with_slack_id], 'message', 10)

        post = Slack::SlackService.create_post(command, team_with_slack.slack_team_id, user_with_slack_id.slack_id)
        expect(post.sender.id).to be(user_with_slack_id.id)
      end
    end
  end

  describe 'list guidelines' do
    let(:guideline) { create(:guideline) }

    it 'raises en error when there is no team with the provided slack id' do
      expect {
        Slack::SlackService.list_guidelines('unusedId')
      }.to raise_exception(Slack::Exceptions::InvalidCommand, 'This workspace does not have an associated Kudo-o-matic team, contact an admin')
    end

    it 'returns a message when there are no guidelines' do
      response = Slack::SlackService.list_guidelines(team_with_slack.slack_team_id)

      expect(response.length).to be(1)
      expect(response[0][:text][:text]).to eq('No guidelines')
    end

    it 'returns the guidelines as a section' do
      guideline.team = team_with_slack
      guideline.save

      response = Slack::SlackService.list_guidelines(team_with_slack.slack_team_id)

      expect(response.length).to be(1)
      expect(response[0][:text][:text]).to eq("• #{guideline.name} *#{guideline.kudos}* \n")
    end
  end

  describe 'get team oauth url' do
    before do
      allow(ENV).to receive(:[]).with("SLACK_CLIENT_ID").and_return("slack-client-id")
      allow(ENV).to receive(:[]).with("SLACK_CLIENT_SECRET").and_return("slack-client-secret")
      allow(ENV).to receive(:[]).with("ROOT_URL").and_return("backend-domain.com")
    end

    it 'calls the generate base method' do
      mock_uri = URI::HTTP.build(host: 'fakedomain.com')
      Slack::SlackService.should_receive(:generate_base_oauth_url).and_return(mock_uri)

      Slack::SlackService.get_team_oauth_url('1')
    end

    it 'sets the query parameters' do
      uri = Slack::SlackService.get_team_oauth_url('1')

      parsed_query = CGI::parse(uri.partition('?').last)
      expect(parsed_query['scope'][0]).to eq('chat:write,commands,incoming-webhook,chat:write.public,reactions:read,channels:history,channels:read,channels:join,users:read')
      expect(parsed_query['client_id'][0]).to eq('slack-client-id')
      expect(parsed_query['redirect_uri'][0]).to eq('https://backend-domain.com/auth/callback/slack/team/1')
    end
  end

  describe 'get user oauth url' do
    before do
      allow(ENV).to receive(:[]).with("SLACK_CLIENT_ID").and_return("slack-client-id")
      allow(ENV).to receive(:[]).with("SLACK_CLIENT_SECRET").and_return("slack-client-secret")
      allow(ENV).to receive(:[]).with("ROOT_URL").and_return("backend-domain.com")
    end

    it 'calls the generate base method' do
      mock_uri = URI::HTTP.build(host: 'fakedomain.com')
      Slack::SlackService.should_receive(:generate_base_oauth_url).and_return(mock_uri)

      Slack::SlackService.get_user_oauth_url('1')
    end

    it 'sets the query parameters' do
      uri = Slack::SlackService.get_user_oauth_url('1')

      parsed_query = CGI::parse(uri.partition('?').last)
      expect(parsed_query['user_scope'][0]).to eq('chat:write')
      expect(parsed_query['client_id'][0]).to eq('slack-client-id')
      expect(parsed_query['redirect_uri'][0]).to eq('https://backend-domain.com/auth/callback/slack/user/1')
    end
  end

  describe 'reaction added' do
    it 'returns if it is a unsupported emoji' do
      event = {
          reaction: 'unsopperted-emoji'
      }

      Slack::SlackService.should_not_receive(:message_is_kudo_o_matic_post?)

      Slack::SlackService.reaction_added(team.id, event.as_json)
    end

    it 'continues if it is a supported emoji' do
      event = {
          reaction: 'kudos-development'
      }

      allow(Slack::SlackService).to receive(:message_is_kudo_o_matic_post?).and_return(true)
      allow(Slack::SlackService).to receive(:like_post)
      allow(Slack::SlackService).to receive(:get_message_from_event)

      expect(Slack::SlackService).to receive(:message_is_kudo_o_matic_post?)
      Slack::SlackService.reaction_added(team_with_slack.slack_team_id, event.as_json)
    end

    it 'likes the post if the message is a kudo-o-matic post' do
      event = {
          user: user_with_slack_id.slack_id,
      }

      message_mock = {
          blocks: [
              {
                  block_id: post.id.to_s
              }
          ]
      }

      allow(Slack::SlackService).to receive(:supported_emoji?).and_return(true)
      allow(Slack::SlackService).to receive(:get_message_from_event).and_return(message_mock.as_json)
      allow(Slack::SlackService).to receive(:message_is_kudo_o_matic_post?).and_return(true)

      expect {
        Slack::SlackService.reaction_added(team_with_slack.slack_team_id, event.as_json)
      }.to change { post.votes.count }.by(1)

    end

    describe 'create post' do
      let(:event) {
        {
            user: user_with_slack_id.slack_id,
            item: {
                channel: 'channelId'
            }
        }
      }
      before do

        allow(Slack::SlackService).to receive(:supported_emoji?).and_return(true)
        allow(Slack::SlackService).to receive(:message_is_kudo_o_matic_post?).and_return(false)
        allow(Slack::SlackService).to receive(:send_post_announcement)
        allow(Slack::SlackService).to receive(:update_message_to_post).and_return(true)
      end

      it 'creates a post if the message is not a kudo-o-matic post' do
        message_mock = {
            user: user_with_slack_id.slack_id,
            text: 'Some text'
        }
        allow(Slack::SlackService).to receive(:get_message_from_event).and_return(message_mock.as_json)

        expect(Slack::SlackService).to receive(:update_message_to_post)
        expect {
          Slack::SlackService.reaction_added(team_with_slack.slack_team_id, event.as_json)
        }.to change { Post.count }.by(1)
      end

      it 'escapes mentioned users' do
        message_mock = {
            user: user_with_slack_id.slack_id,
            text: 'Thanks for helping me <@SOMEID>!'
        }

        user_info_mock = {
            user: {
                name: 'max'
            }
        }
        allow(Slack::SlackService).to receive(:get_message_from_event).and_return(message_mock.as_json)
        allow_any_instance_of(Slack::Web::Client).to receive(:users_info).and_return(user_info_mock.as_json)

        Slack::SlackService.reaction_added(team_with_slack.slack_team_id, event.as_json)
        expect(Post.last.message).to eq("saying: 'Thanks for helping me max!'")
      end
    end

  end

  describe 'reaction_removed' do
    it 'returns if it is a unsupported emoji' do
      event = {
          reaction: 'unsopperted-emoji'
      }

      Slack::SlackService.should_not_receive(:message_is_kudo_o_matic_post?)

      Slack::SlackService.reaction_removed(team.id, event.as_json)
    end

    it 'continues if it is a supported emoji' do
      event = {
          reaction: 'kudos-development'
      }

      allow(Slack::SlackService).to receive(:message_is_kudo_o_matic_post?).and_return(true)
      allow(Slack::SlackService).to receive(:unlike_post)
      allow(Slack::SlackService).to receive(:get_message_from_event)

      expect(Slack::SlackService).to receive(:message_is_kudo_o_matic_post?)
      Slack::SlackService.reaction_removed(team.id, event.as_json)
    end

    it 'unlikes the post if it is liked by the user' do
      event = {
          reaction: 'kudos-development',
          user: user_with_slack_id.slack_id
      }

      message = {
          blocks: [
              {
                  block_id: post.id
              }
          ]
      }

      allow(Slack::SlackService).to receive(:get_message_from_event).and_return(message.as_json)
      post.liked_by(user_with_slack_id)

      expect {
        Slack::SlackService.reaction_removed(team_with_slack.slack_team_id, event.as_json)
      }.to change { post.votes.count }.by(-1)
    end

    it 'does not unlikes the post if it is not liked by the user' do
      event = {
          reaction: 'kudos-development',
          user: user_with_slack_id.slack_id
      }

      message = {
          blocks: [
              {
                  block_id: post.id
              }
          ]
      }

      allow(Slack::SlackService).to receive(:get_message_from_event).and_return(message.as_json)

      expect {
        Slack::SlackService.reaction_removed(team_with_slack.slack_team_id, event.as_json)
      }.to_not change { post.votes.count }
    end
  end
end