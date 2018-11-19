# frozen_string_literal: true

RSpec.describe QueryTypes::PostQueryType do
  # available type definer in tests
  types = GraphQL::Define::TypeDefiner.instance

  let(:users) { create_list(:user, 3) }
  let(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let!(:posts) { create_list(:post, 3, sender: users.first, receivers: [users.second, users.last], team: team, kudos_meter: kudos_meter) }

  describe "querying all posts" do
    it "has a :postsConnection field that returns a PostConnection connection" do
      expect(subject).to have_field(:postsConnection).that_returns(Connections::PostsConnection)
    end

    it "accepts a orderBy argument, of type String" do
      expect(subject.fields["postsConnection"]).to accept_arguments(orderBy: types.String)
    end

    it "accepts a findByTeamID argument, of type ID" do
      expect(subject.fields["postsConnection"]).to accept_arguments(findByTeamId: !types.ID)
    end

    it "returns all created posts" do
      args = { findByTeamId: team.id }
      query_result = subject.fields["postsConnection"].resolve(nil, args, nil)

      posts.each do |post|
        expect(query_result.to_a).to include(post)
      end

      expect(query_result.count).to eq(posts.count)
    end
  end

  describe "querying a specific post by id" do
    it "has :post that returns a Post type" do
      expect(subject).to have_field(:postById).that_returns(Types::PostType)
    end

    it "accepts a id argument, of type !ID" do
      expect(subject.fields["postById"]).to accept_arguments(id: !types.ID)
    end

    it "returns the queried post" do
      id = posts.first.id
      args = { id: id }
      query_result = subject.fields["postById"].resolve(nil, args, nil)
      expect(query_result).to eq(posts.first)
    end
  end
end
