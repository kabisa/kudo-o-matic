# frozen_string_literal: true

RSpec.describe Types::TeamMemberType do
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID! type" do
    expect(subject).to have_field(:id).that_returns('ID!')
  end

  it "has a :team field of TeamType! type" do
    expect(subject).to have_field(:team).that_returns('Team!')
  end

  it "has a :user field of UserType! type" do
    expect(subject).to have_field(:user).that_returns('User!')
  end

  it "has a :user field of UserType! type" do
    expect(subject).to have_field(:user).that_returns('User!')
  end

  it "has a :role field of String! type" do
    expect(subject).to have_field(:role).that_returns('String!')
  end

  it "has a :createdAt field of ISO8601DateTime type" do
    expect(subject).to have_field(:createdAt).that_returns('ISO8601DateTime')
  end

  it "has a :updatedAt field of ISO8601DateTime type" do
    expect(subject).to have_field(:updatedAt).that_returns('ISO8601DateTime')
  end
end
