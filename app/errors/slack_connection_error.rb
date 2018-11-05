# frozen_string_literal: true

class SlackConnectionError < StandardError
  def initialize(message)
    super(message)
  end
end
