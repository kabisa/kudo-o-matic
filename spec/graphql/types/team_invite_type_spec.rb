# frozen_string_literal: true

RSpec.describe Types::TeamInviteType do
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID! type" do
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has an :email field of EmailAddress! type" do
    expect(subject).to have_field(:email).that_returns(!Types::EmailAddress)
  end

  it "has a :team field of TeamType! type" do
    expect(subject).to have_field(:team).that_returns(!Types::TeamType)
  end

  xit "has an :acceptedAt field of ISO8601DateTime type" do
    expect(subject).to have_field(:acceptedAt).that_returns(GraphQL::Types::ISO8601DateTime)
  end

  xit "has a :declinedAt field of ISO8601DateTime type" do
    expect(subject).to have_field(:declinedAt).that_returns(GraphQL::Types::ISO8601DateTime)
  end

  xit "has a :sentAt field of ISO8601DateTime type" do
    expect(subject).to have_field(:sentAt).that_returns(GraphQL::Types::ISO8601DateTime)
  end
end
