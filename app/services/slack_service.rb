class SlackService
  extend Slack::Auth
  extend Slack::Command
  extend Slack::Event
  extend Slack::Message
  extend Slack::Support
end
