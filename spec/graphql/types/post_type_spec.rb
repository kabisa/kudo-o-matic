# frozen_string_literal: true

RSpec.describe Types::PostType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID type" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has an :sender field of UserType" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:sender).that_returns(!Types::UserType)
  end

  it "has an :receivers field of an array UserType" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:receivers).that_returns(!types[Types::UserType])
  end


  it "has a :message field of String type" do
    # Ensure the field is of String type
    expect(subject).to have_field(:message).that_returns(!types.String)
  end

  it "has a :kudos field of Integer type" do
    # Ensure the field is of String type
    expect(subject).to have_field(:amount).that_returns(!types.Int)
  end
end
