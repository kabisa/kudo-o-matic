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

  it "has a :amount field of Integer type" do
    expect(subject).to have_field(:amount).that_returns(!types.Int)
  end

  it "has an :sender field of UserType" do
    expect(subject).to have_field(:sender).that_returns(!Types::UserType)
  end

  it "has an :receivers field of an array UserType" do
    expect(subject).to have_field(:receivers).that_returns(!types[Types::UserType])
  end

  it "has an :team field of TeamType" do
    expect(subject).to have_field(:team).that_returns(!Types::TeamType)
  end

  it "has an :kudosMeter field of KudosMeterType" do
    expect(subject).to have_field(:kudosMeter).that_returns(!Types::KudosMeterType)
  end

  it "has an :votes field of VoteType" do
    expect(subject).to have_field(:votes).that_returns(!types[Types::VoteType])
  end
end
