# frozen_string_literal: true

require "graphlient"

RSpec.describe Connections::PostsConnection do
  # avail type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance
  let!(:users) { create_list(:user, 3) }
  let(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let!(:posts) { create_list(:post, 3, sender: users.first, receivers: [users.second, users.last], team: team, kudos_meter: kudos_meter) }

  include_context "Graphql Client"

  it "has a :totalCount field that returns a Int type" do
    expect(subject).to have_field(:totalCount).that_returns(types.Int)
  end

  it "returns the number of nodes" do
    response = client.query do
      query do
        postsConnection do
          totalCount
        end
      end
    end

    expect(response.data.posts_connection.total_count).to eq(Post.count)
  end
end
