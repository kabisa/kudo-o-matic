# frozen_string_literal: true

RSpec.describe QueryTypes::UserQueryType do
  # avail type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  let!(:users) { create_list(:user, 3) }

  describe "querying all users" do
    it "has a :users field that returns a User type" do
      expect(subject).to have_field(:users).that_returns(types[Types::UserType])
    end

    it 'accepts a orderBy and a findByName argument, of type String' do
      expect(subject.fields["users"]).to accept_arguments(orderBy: types.String, findByName: types.String)
    end

    it "returns all created users" do
      args = {}
      query_result = subject.fields["users"].resolve(nil, args, nil)

      users.each do |user|
        expect(query_result.to_a).to include(user)
      end

      expect(query_result.count).to eq(users.count)
    end
  end

  describe "querying a specific user by id" do
    it "has a field :userById that returns a User type" do
      expect(subject).to have_field(:userById).that_returns(Types::UserType)
    end

    it 'accepts a id argument, of type !ID' do
      expect(subject.fields["userById"]).to accept_argument(id: !types.ID)
    end

    it "returns the queried user" do
      id = users.first.id
      args = { id: id }
      query_result = subject.fields["userById"].resolve(nil, args, nil)
      expect(query_result).to eq(users.first)
    end
  end
end
