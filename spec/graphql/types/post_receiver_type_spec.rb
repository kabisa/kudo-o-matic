# frozen_string_literal: true

RSpec.describe Types::PostReceiverType do
  set_graphql_type

  it "has an :id field of ID type" do
    expect(subject.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it "has an :user field of UserType" do
    expect(subject.fields['user'].type.to_type_signature).to eq('User!')
  end

  it "has an :post field of PostType" do
    expect(subject.fields['post'].type.to_type_signature).to eq('Post!')
  end

  it "has a :created_at field of ISO8601DateTime type" do
    expect(subject.fields['createdAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end

  it "has a :updated_at field of ISO8601DateTime type" do
    expect(subject.fields['updatedAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end
end
