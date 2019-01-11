# frozen_string_literal: true

RSpec.describe Types::KudosMeterType do
  set_graphql_type

  it "has an :id field of ID! type" do
    expect(subject.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it "has a :name field of String! type" do
    expect(subject.fields['name'].type.to_type_signature).to eq('String!')
  end

  it "has an :amount field of Int! type" do
    expect(subject.fields['amount'].type.to_type_signature).to eq('Int!')
  end

  it "has a :team field of Team! type" do
    expect(subject.fields['team'].type.to_type_signature).to eq('Team!')
  end

  it "has a :created_at field of ISO8601DateTime type" do
    expect(subject.fields['createdAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end

  it "has a :updated_at field of ISO8601DateTime type" do
    expect(subject.fields['updatedAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end
end
