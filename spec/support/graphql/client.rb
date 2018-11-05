# frozen_string_literal: true

require "active_record"
require "graphlient"

RSpec.shared_context "Graphql Client", shared_context: :metadata do
  include Rack::Test::Methods

  let(:client) do
    Graphlient::Client.new("http://api-example.com/graphql") do |client|
      client.http do |h|
        h.connection do |c|
          c.use Faraday::Adapter::Rack, Rails.application
        end
      end
    end
  end
end
