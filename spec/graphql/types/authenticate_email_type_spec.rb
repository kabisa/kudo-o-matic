# frozen_string_literal: true

RSpec.describe Types::AuthenticateEmailType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :email field of EmailAddress type" do
    expect(subject).to have_field(:email).that_returns(Types::EmailAddress)
  end
end
