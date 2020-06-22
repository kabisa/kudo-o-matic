# frozen_string_literal: true
FactoryBot.define do
  factory :team do
    name { "The Team name" }
  end

  trait :with_slack do
    slack_bot_access_token { 'accessToken' }
    channel_id { 'channelId' }
    slack_team_id { 'slackTeamId' }
  end
end
