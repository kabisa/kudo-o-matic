# frozen_string_literal: true

RSpec.describe Types::AuthProviderSignupInput do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has a :name input field of String type" do
    expect(subject).to have_an_input_field(:name).of_type('String')
  end

  it "has an :email input field of String type" do
    expect(subject).to have_an_input_field(:email).of_type('EmailAddress')
  end

  it "has an :password input field of String type" do
    expect(subject).to have_an_input_field(:password).of_type('String')
  end

  it "has an :password_confirmation input field of String type" do
    expect(subject).to have_an_input_field(:password_confirmation).of_type('String')
  end
end
