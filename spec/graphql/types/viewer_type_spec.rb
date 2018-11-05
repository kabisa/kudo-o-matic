# frozen_string_literal: true

RSpec.describe Types::ViewerType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :self field of UserType" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:self).that_returns(Types::UserType)
  end

  it "returns an user object" do
    user = create(:user)
    query_result = subject.fields["self"].resolve(user, nil, nil)

    expect(query_result).to eq(user)
  end
end
