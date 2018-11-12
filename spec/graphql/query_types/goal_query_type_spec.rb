# frozen_string_literal: true

RSpec.describe QueryTypes::GoalQueryType do
  # available type definer in tests
  types = GraphQL::Define::TypeDefiner.instance

  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:goals) { team.current_goals }

  describe "querying all goals" do
    it "has a :goals field that returns an array of GoalsType types" do
      expect(subject).to have_field(:goals).that_returns(types[Types::GoalType])
    end

    it "accepts a orderBy argument of type String" do
      expect(subject.fields["goals"]).to accept_arguments(orderBy: types.String)
    end

    it "returns all created goals" do
      args = {}
      query_result = subject.fields["goals"].resolve(nil, args, nil)

      goals.each do |goal|
        expect(query_result.to_a).to include(goal)
      end

      expect(query_result.count).to eq(goals.count)
    end
  end

  describe "querying a specific goal by id" do
    it "has a field :goalById that returns a GoalType type" do
      expect(subject).to have_field(:goalById).that_returns(Types::GoalType)
    end

    it "accepts a id argument, of type !ID" do
      expect(subject.fields["goalById"]).to accept_arguments(id: !types.ID)
    end

    it "returns the queried goal" do
      id = goals.first.id
      args = { id: id }
      query_result = subject.fields["goalById"].resolve(nil, args, nil)
      expect(query_result).to eq(goals.first)
    end
  end
end
