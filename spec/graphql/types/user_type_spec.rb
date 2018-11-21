# frozen_string_literal: true

RSpec.describe Types::UserType do
  types = GraphQL::Define::TypeDefiner.instance

  it "has an :id field of ID type" do
    # Ensure that the field id is of type !ID
    expect(subject).to have_field(:id).that_returns(!types.ID)
  end

  it "has a :name field of String type" do
    # Ensure the field is of !String type
    expect(subject).to have_field(:name).that_returns(!types.String)
  end

  it "has a :email field of EmailAddress type" do
    # Ensure the field is of !EmailAddress type
    expect(subject).to have_field(:email).that_returns(!Types::EmailAddress)
  end

  it "has a :sent_posts field of an array PostType" do
    # Ensure the field is of an array of !PostType type
    expect(subject).to have_field(:sentPosts).that_returns(!types[Types::PostType])
  end

  it "has a :received_posts field of an array PostType" do
    # Ensure the field is of an array of !PostType type
    expect(subject).to have_field(:receivedPosts).that_returns(!types[Types::PostType])
  end

  it "has a :teamInvites field of an array TeamInviteType" do
    expect(subject).to have_field(:teamInvites).that_returns(!types[Types::TeamInviteType])
  end
end
