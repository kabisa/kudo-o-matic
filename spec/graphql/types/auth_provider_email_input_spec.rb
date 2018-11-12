# frozen_string_literal: true

RSpec.describe Types::AuthProviderEmailInput do
  # available type definer in tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :email input field of String type" do
    # Ensure that the field email is of type String
    expect(subject).to have_an_input_field(:email).of_type(!Types::EmailAddress)
  end
end
