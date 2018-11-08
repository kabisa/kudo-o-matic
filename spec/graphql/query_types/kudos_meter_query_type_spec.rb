# frozen_string_literal: true

RSpec.describe QueryTypes::KudosMeterQueryType do
  # available type definer in tests
  types = GraphQL::Define::TypeDefiner.instance

  let(:users) { create_list(:user, 5) }
  let(:team) { create(:team) }

  before do
    users.each do |user|
      team.add_member(user)
    end
  end

  let(:kudos_meters) { create_list(:kudos_meter, 5) }
  let(:active_kudos_meter) { team.active_kudos_meter }
  let!(:post) { create(:post, sender: users.first, receivers: [users.second, users.third], team: team, kudos_meter: active_kudos_meter) }

  describe "querying all kudos meters" do
    it "has a :kudosMeters field that returns a KudosMeterType type" do
      expect(subject).to have_field(:kudosMeters).that_returns(types[Types::KudosMeterType])
    end

    it "accepts a orderBy argument, of type String" do
      expect(subject.fields["kudosMeters"]).to accept_arguments(orderBy: types.String)
    end

    it "returns all created kudos meters" do
      args = {}
      query_result = subject.fields["kudosMeters"].resolve(nil, args, nil)

      KudosMeter.all.each do |kudos_meter|
        expect(query_result.to_a).to include(kudos_meter)
      end

      expect(query_result.count).to eq(KudosMeter.count)
    end
  end

  describe "querying a specific kudos meter by id" do
    it "has a field :kudosMeterById that returns a KudosMeterType type" do
      expect(subject).to have_field(:kudosMeterById).that_returns(Types::KudosMeterType)
    end

    it "accepts a id argument, of type !ID" do
      expect(subject.fields["kudosMeterById"]).to accept_arguments(id: !types.ID)
    end

    it "returns the queried kudos meter" do
      id = kudos_meters.first.id
      args = { id: id }
      query_result = subject.fields["kudosMeterById"].resolve(nil, args, nil)
      expect(query_result).to eq(kudos_meters.first)
    end
  end
end
