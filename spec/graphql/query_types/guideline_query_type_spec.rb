RSpec.describe QueryTypes::GuidelineQueryType do
  # available type definer in tests
  types = GraphQL::Define::TypeDefiner.instance

  let!(:team) { create(:team) }
  let(:guidelines) { create_list(:guideline, 10, team: team) }

  describe "querying all guidelines" do
    it "has a :guidelines field that returns a array of GuidelineType types" do
      expect(subject).to have_field(:guidelines).that_returns(types[Types::GuidelineType])
    end

    it "accepts a orderBy argument of type String" do
      expect(subject.fields["guidelines"]).to accept_arguments(orderBy: types.String)
    end

    it "returns all created guidelines of a team" do
      args = {}
      query_result = subject.fields["guidelines"].resolve(nil, args, nil)

      guidelines.each do |guideline|
        expect(query_result.to_a).to include(guideline)
      end

      expect(query_result.count).to eq(guidelines.count)
    end
  end

  describe "querying a specific guideline by id" do
    it "has a field :guidelineById that returns a GuidelineType type" do
      expect(subject).to have_field(:guidelineById).that_returns(Types::GuidelineType)
    end

    it "accepts a id argument, of type !ID" do
      expect(subject.fields["guidelineById"]).to accept_arguments(id: !types.ID)
    end

    it "returns the queried guideline" do
      id = guidelines.first.id
      args = { id: id }
      query_result = subject.fields["guidelineById"].resolve(nil, args, nil)
      expect(query_result).to eq(guidelines.first)
    end
  end
end