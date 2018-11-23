# frozen_string_literal: true

RSpec.describe Types::PostType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID type" do
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :message field of String type" do
    expect(subject).to have_field(:message).that_returns(!types.String)
  end

  it "has an :amount field of Integer type" do
    expect(subject).to have_field(:amount).that_returns(!types.Int)
  end

  it "has a :sender field of UserType" do
    expect(subject).to have_field(:sender).that_returns(!Types::UserType)
  end

  it "has a :receivers field of an array UserType" do
    expect(subject).to have_field(:receivers).that_returns(!types[Types::UserType])
  end

  it "has a :team field of TeamType" do
    expect(subject).to have_field(:team).that_returns(!Types::TeamType)
  end

  it "has a :kudosMeter field of KudosMeterType" do
    expect(subject).to have_field(:kudosMeter).that_returns(!Types::KudosMeterType)
  end

  it "has a :votes field of VoteType" do
    expect(subject).to have_field(:votes).that_returns(!types[Types::VoteType])
  end

  it "has a :createdAt field of ISO8601DateTime type" do
    expect(subject).to have_field(:createdAt).that_returns('ISO8601DateTime')
  end

  it "has a :updatedAt field of ISO8601DateTime type" do
    expect(subject).to have_field(:updatedAt).that_returns('ISO8601DateTime')
  end
end
