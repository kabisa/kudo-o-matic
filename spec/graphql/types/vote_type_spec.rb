# frozen_string_literal: true

RSpec.describe Types::VoteType do
  set_graphql_type

  it "has an :id field of ID! type" do
    expect(subject.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it "has a :votedOn field of !PostType type" do
    expect(subject.fields['votedOn'].type.to_type_signature).to eq('Post!')
  end

  it "has a :voter field of !UserType type" do
    expect(subject.fields['voter'].type.to_type_signature).to eq('User!')
  end

  it "has a :voteWeight field of !Int type" do
    expect(subject.fields['voteWeight'].type.to_type_signature).to eq('Int!')
  end
end
