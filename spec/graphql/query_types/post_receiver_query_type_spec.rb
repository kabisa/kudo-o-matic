# frozen_string_literal: true

RSpec.describe QueryTypes::PostReceiverQueryType do
  # avail type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  let!(:users) { create_list(:user, 3) }
  let!(:posts) { create_list(:post, 3, sender: users.first, receivers: [users.second, users.last]) }

  describe "querying all posts receivers" do
    it "has a :posts_receivers that returns a PostReceiver type" do
      expect(subject).to have_field(:postReceivers).that_returns(types[Types::PostReceiverType])
    end

    it "returns all our created posts" do
      args = {}
      query_result = subject.fields["postReceivers"].resolve(nil, args, nil)
      post_receivers = PostReceiver.all

      post_receivers.each do |post_receiver|
        expect(query_result.to_a).to include(post_receiver)
      end

      expect(query_result.count).to eq(post_receivers.count)
    end
  end
end
