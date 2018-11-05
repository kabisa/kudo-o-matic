# frozen_string_literal: true

RSpec.describe Types::TeamType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID type" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :name field of String type" do
    # Ensure the field is of String type
    expect(subject).to have_field(:name).that_returns(!types.String)
  end

  it "has a :slug field of String type" do
    # Ensure the field is of String type
    expect(subject).to have_field(:slug).that_returns(!types.String)
  end

  it "has a :memberships field of UserType type" do
    # Ensure the field is of UserType type
    expect(subject).to have_field(:memberships).that_returns(!types[Types::UserType])
  end
end
