# frozen_string_literal: true

RSpec.describe QueryTypes::TeamQueryType do
  # avail type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  let!(:teams) { create_list(:team, 3) }

  describe "querying all teams" do
    it "has a :teams field that returns a TeamType type" do
      expect(subject).to have_field(:teams).that_returns(types[Types::TeamType])
    end

    it 'accepts a orderBy argument, of type String' do
      expect(subject.fields["teams"]).to accept_arguments(orderBy: types.String)
    end

    it "returns all teams" do
      args = {}
      query_result = subject.fields["teams"].resolve(nil, args, nil)

      teams.each do |team|
        expect(query_result.to_a).to include(team)
      end

      expect(query_result.count).to eq(teams.count)
    end
  end

  describe "querying a specific team by id" do
    it "has a field :teamById that returns a Team type" do
      expect(subject).to have_field(:teamById).that_returns(Types::TeamType)
    end

    it 'accepts a id argument, of type !ID' do
      expect(subject.fields["teamById"]).to accept_argument(id: !types.ID)
    end

    it "returns the queried team" do
      id = teams.first.id
      args = { id: id }
      query_result = Functions::FindById.new(Team).call(nil, args, nil)
      expect(query_result).to eq(teams.first)
    end
  end
end
