# frozen_string_literal: true

RSpec.describe Types::VoteType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of !ID type" do
    # Ensure that the field id is of !ID type
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :votedOn field of !PostType type" do
    # Ensure the field is of String type
    expect(subject).to have_field(:votedOn).that_returns(!Types::PostType)
  end

  it "has a :voter field of !UserType type" do
    # Ensure the field is of !ID type
    expect(subject).to have_field(:voter).that_returns(!Types::UserType)
  end

  it "has a :vote_weight field of !Int type" do
    # Ensure the field is of !ID type
    expect(subject).to have_field(:vote_weight).that_returns(!types.Int)
  end
end
