# frozen_string_literal: true

RSpec.describe Types::VoteType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of !ID type" do
    # Ensure that the field id is of !ID type
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :votable_type field of !String type" do
    # Ensure the field is of String type
    expect(subject).to have_field(:votable_type).that_returns(!types.String)
  end

  it "has a :votable_id field of !ID type" do
    # Ensure the field is of !ID type
    expect(subject).to have_field(:votable_id).that_returns(!types.ID)
  end

  it "has a :voter_type field of !String type" do
    # Ensure the field is of !String type
    expect(subject).to have_field(:voter_type).that_returns(!types.String)
  end

  it "has a :voter_id field of !ID type" do
    # Ensure the field is of !ID type
    expect(subject).to have_field(:voter_id).that_returns(!types.ID)
  end

  it "has a :vote_weight field of !Int type" do
    # Ensure the field is of !ID type
    expect(subject).to have_field(:vote_weight).that_returns(!types.Int)
  end
end
