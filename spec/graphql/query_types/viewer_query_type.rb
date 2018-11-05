# frozen_string_literal: true

RSpec.describe QueryTypes::ViewerQueryType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has :self that returns a User type" do
    expect(subject).to have_field(:viewer).that_returns(Types::ViewerType)
  end

  context "when viewer is logged in" do
    describe "querying the viewer" do
      it "returns the current user as viewer" do
        viewer = create(:user)
        context = { current_user: viewer }
        query_result = subject.fields["viewer"].resolve(nil, nil, context)

        # ensure that current user is returned
        expect(query_result).to eq(viewer)
      end
    end
  end

  context "when viewer is not logged in" do
    describe "querying the viewer" do
      it "returns Authentication required" do
        ctx = { current_user: nil }

        # ensure that viewer should authenticate first
        expect do
          subject.fields["viewer"].resolve(nil, nil, ctx)
        end.to raise_error(GraphQL::ExecutionError, "Authentication required")
      end
    end
  end
end
