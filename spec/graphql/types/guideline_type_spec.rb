RSpec.describe Types::GuidelineType do
  # available type definer in tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID! type" do
    # Ensure that the field id is of type !ID
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :name field of String! type" do
    # Ensure that the field name is of type !String
    expect(subject).to have_field(:name).that_returns(!types.String)
  end

  it "has a :kudos field of Int! type" do
    # Ensure that the field suggested_amount is of type !Int
    expect(subject).to have_field(:kudos).that_returns(!types.Int)
  end

  it "has a :team field of TeamType! type" do
    # Ensure that the field team is of type !TeamType
    expect(subject).to have_field(:team).that_returns(!Types::TeamType)
  end
end