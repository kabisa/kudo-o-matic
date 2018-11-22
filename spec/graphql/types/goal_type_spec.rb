# frozen_string_literal: true

RSpec.describe Types::GoalType do
  # available type definer in tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID! type" do
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :name field of String! type" do
    expect(subject).to have_field(:name).that_returns(!types.String)
  end

  it "has an :amount field of Int! type" do
    expect(subject).to have_field(:amount).that_returns(!types.Int)
  end

  it "has a :achieved_on field of Date type" do
    expect(subject).to have_field(:achieved_on).that_returns(Types::Date)
  end

  it "has a :kudosMeter field of KudosMeterType! type" do
    expect(subject).to have_field(:kudosMeter).that_returns(!Types::KudosMeterType)
  end
end
