# frozen_string_literal: true

RSpec.describe QueryTypes::UserQueryType do
  # avail type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  let!(:users) { create_list(:user, 3) }

  describe "querying all users" do
    it "has a :users field that returns a User type" do
      expect(subject).to have_field(:users).that_returns(types[Types::UserType])
    end

    it "returns all our created users" do
      args = {}
      query_result = subject.fields["users"].resolve(nil, args, nil)

      # ensure that each of our users is returned
      users.each do |user|
        expect(query_result.to_a).to include(user)
      end

      # we can also check that the number of lists returned is the one we created.
      expect(query_result.count).to eq(users.count)
    end
  end

  describe "querying a specific user by id" do
    it "has a field :userById that returns a User type" do
      expect(subject).to have_field(:userById).that_returns(Types::UserType)
    end

    it "returns the queried user" do
      id = users.first.id
      args = { id: id }
      query_result = Functions::FindById.new(User).call(nil, args, nil)
      expect(query_result).to eq(users.first)
    end
  end

  describe "querying a users by ordering" do
    it "returns the queried user" do
      ordered_users = User.all.order("created_at desc")
      args = { order: "created_at desc" }
      query_result = Functions::FindAll.new(User).call(nil, args, nil)
      expect(query_result).to eq(ordered_users)
    end
  end
end
