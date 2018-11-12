# frozen_string_literal: true

RSpec.describe Types::GoalType do
  # available type definer in tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID! type" do
    # Ensure that the field id is of type ID!
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :name field of String! type" do
    # Ensure that the field name is of type String!
    expect(subject).to have_field(:name).that_returns(!types.String)
  end

  it "has an :amount field of Int! type" do
    # Ensure that the field amount is of type Int!
    expect(subject).to have_field(:amount).that_returns(!types.Int)
  end

  it "has a :achieved_on field of Date type" do
    # Ensure that the field achieved_on is of type Date
    expect(subject).to have_field(:achieved_on).that_returns(Types::Date)
  end

  it "has a :kudosMeter field of KudosMeterType! type" do
    # Ensure that the field kudosMeter is of type KudosMeterType
    expect(subject).to have_field(:kudosMeter).that_returns(!Types::KudosMeterType)
  end
end
