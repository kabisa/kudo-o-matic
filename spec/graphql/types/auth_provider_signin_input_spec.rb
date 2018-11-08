# frozen_string_literal: true

RSpec.describe Types::AuthProviderSignupInput do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :email input field of String type" do
    # Ensure that the field email is of type String
    expect(subject).to have_an_input_field(:email).of_type(!Types::EmailAddress)
  end

  it "has an :password input field of String type" do
    # Ensure that the field password is of type String
    expect(subject).to have_an_input_field(:password).of_type(!types.String)
  end
end
