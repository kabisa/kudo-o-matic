# frozen_string_literal: true

RSpec.describe Types::KudosMeterType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID type" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :name field of String type" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:name).that_returns(!types.String)
  end

  it "has an :amount field of Int type" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:amount).that_returns(!types.Int)
  end

  it "has a :team field of TeamType type" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:team).that_returns(!Types::TeamType)
  end
end
