# frozen_string_literal: true

RSpec.describe Types::AuthProviderSigninInput do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :email input field of String type" do
    expect(subject).to have_an_input_field(:email).of_type(!Types::EmailAddress)
  end

  it "has an :password input field of String type" do
    expect(subject).to have_an_input_field(:password).of_type(!types.String)
  end
end
