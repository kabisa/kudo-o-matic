# frozen_string_literal: true

RSpec.describe Types::PostReceiverType do
  # available type definer in our tests
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID type" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has an :user_id field of UserType" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:userId).that_returns(!Types::UserType)
  end

  it "has an :post_id field of PostType" do
    # Ensure that the field id is of type ID
    expect(subject).to have_field(:postId).that_returns(!Types::PostType)
  end
end
