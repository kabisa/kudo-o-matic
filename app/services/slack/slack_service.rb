module Slack
  class SlackService
    extend Auth
    extend Command
    extend Event
    extend Message
    extend Support

    class InvalidRequest < RuntimeError; end

    class InvalidCommand < RuntimeError; end
  end
end