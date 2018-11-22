# frozen_string_literal: true

RSpec.describe Types::TeamType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID type" do
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :name field of String type" do
    expect(subject).to have_field(:name).that_returns(!types.String)
  end

  it "has a :slug field of String type" do
    expect(subject).to have_field(:slug).that_returns(!types.String)
  end

  it "has a :memberships field of an array UserType! type" do
    expect(subject).to have_field(:memberships).that_returns(!types[Types::UserType])
  end

  it "has a :posts field of an array PostType! type" do
    expect(subject).to have_field(:posts).that_returns(!types[Types::PostType])
  end

  it "has a :kudosMeters field of an array KudosMeterType! type" do
    expect(subject).to have_field(:kudosMeters).that_returns(!types[Types::KudosMeterType])
  end

  it "has a :activeKudosMeter field of KudosMeterType! type" do
    expect(subject).to have_field(:activeKudosMeter).that_returns(!Types::KudosMeterType)
  end

  it "has a :goals field of an array GoalType! type" do
    expect(subject).to have_field(:kudosMeters).that_returns(!types[Types::KudosMeterType])
  end

  it "has a :activeGoals field of an array GoalType! type" do
    expect(subject).to have_field(:activeGoals).that_returns(!types[Types::GoalType])
  end

  it "has a :teamInvites field of an array TeamInviteType" do
    expect(subject).to have_field(:teamInvites).that_returns(!types[Types::TeamInviteType])
  end

  it "has a :guidelines field of an array GuidelineType! type" do
    expect(subject).to have_field(:guidelines).that_returns(!types[Types::GuidelineType])
  end
end
