# frozen_string_literal: true

RSpec.describe Types::UserType do
  set_graphql_type

  it "has an :id field of ID type" do
    expect(subject.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it "has a :name field of String type" do
    expect(subject.fields['name'].type.to_type_signature).to eq('String!')
  end

  it "has a :email field of EmailAddress type" do
    expect(subject.fields['email'].type.to_type_signature).to eq('EmailAddress!')
  end

  it "has a :sent_posts field of an array PostType" do
    expect(subject.fields['sentPosts'].type.to_type_signature).to eq('[Post!]!')
  end

  it "has a :received_posts field of an array PostType" do
    expect(subject.fields['receivedPosts'].type.to_type_signature).to eq('[Post!]!')
  end

  it "has a :teamInvites field of an array TeamInviteType" do
    expect(subject.fields['teamInvites'].type.to_type_signature).to eq('[TeamInvite!]!')
  end

  it "has a :teams field of an array TeamType" do
    expect(subject.fields['teams'].type.to_type_signature).to eq('[Team!]!')
  end

  it "has a :teams field of an array TeamType!" do
    expect(subject.fields['teams'].type.to_type_signature).to eq('[Team!]!')
  end

  it "has a :memberships field of an array TeamMemberType" do
    expect(subject.fields['memberships'].type.to_type_signature).to eq('[TeamMember!]!')
  end

  it "has an :admin field of Boolean type" do
    expect(subject.fields['admin'].type.to_type_signature).to eq('Boolean')
  end

  it "has an :virtual_user field of Boolean type" do
    expect(subject.fields['virtualUser'].type.to_type_signature).to eq('Boolean')
  end
end
