# frozen_string_literal: true

RSpec.describe QueryTypes::PostQueryType do
  # avail type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  let!(:users) { create_list(:user, 3) }
  let!(:posts) { create_list(:post, 3, sender: users.first, receivers: [users.second, users.last]) }

  describe "querying all posts" do
    it "has :postsConnection field that returns a Post type" do
      expect(subject).to have_field(:postsConnection).that_returns(Connections::PostsConnection)
    end

    it "returns all created posts" do
      args = { order_by: "created_at desc" }
      query_result = subject.fields["postsConnection"].resolve(nil, args, nil)

      posts.each do |post|
        expect(query_result.to_a).to include(post)
      end

      expect(query_result.count).to eq(posts.count)
    end

    it "accepts a orderBy argument, of type String" do
      expect(subject.fields["postsConnection"]).to accept_arguments(orderBy: types.String)
    end
  end

  describe "querying a specific post by id" do
    it "has :post that returns a Post type" do
      expect(subject).to have_field(:postById).that_returns(Types::PostType)
    end

    it "returns the queried post" do
      id = posts.first.id
      args = { id: id }
      query_result = Functions::FindById.new(Post).call(nil, args, nil)
      expect(query_result).to eq(posts.first)
    end
  end
end
