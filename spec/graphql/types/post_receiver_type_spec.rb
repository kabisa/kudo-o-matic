# frozen_string_literal: true

RSpec.describe Types::PostReceiverType do
  # available type definer in tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID type" do
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has an :user_id field of UserType" do
    expect(subject).to have_field(:userId).that_returns(!Types::UserType)
  end

  it "has an :post_id field of PostType" do
    expect(subject).to have_field(:postId).that_returns(!Types::PostType)
  end
end
