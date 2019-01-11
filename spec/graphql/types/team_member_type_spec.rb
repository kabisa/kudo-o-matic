# frozen_string_literal: true

RSpec.describe Types::TeamMemberType do
  set_graphql_type

  it "has an :id field of ID! type" do
    expect(subject.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it "has a :team field of TeamType! type" do
    expect(subject.fields['team'].type.to_type_signature).to eq('Team!')
  end

  it "has a :user field of UserType! type" do
    expect(subject.fields['user'].type.to_type_signature).to eq('User!')
  end

  it "has a :role field of String! type" do
    expect(subject.fields['role'].type.to_type_signature).to eq('String!')
  end

  it "has a :createdAt field of ISO8601DateTime! type" do
    expect(subject.fields['createdAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end

  it "has a :updatedAt field of ISO8601DateTime! type" do
    expect(subject.fields['updatedAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end
end
