# frozen_string_literal: true

RSpec.describe Types::AuthenticateType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :token field of String type" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:token).that_returns(types.String)
  end

  it "has an :user_id field of UserType" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:user).that_returns(Types::UserType)
  end
end
