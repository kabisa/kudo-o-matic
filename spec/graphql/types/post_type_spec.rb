# frozen_string_literal: true

RSpec.describe Types::PostType do
  set_graphql_type

  it "has an :id field of ID type" do
    expect(subject.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it "has a :message field of String type" do
    expect(subject.fields['message'].type.to_type_signature).to eq('String!')
  end

  it "has an :amount field of Integer type" do
    expect(subject.fields['amount'].type.to_type_signature).to eq('Int!')
  end

  it "has a :sender field of UserType" do
    expect(subject.fields['sender'].type.to_type_signature).to eq('User!')
  end

  it "has a :receivers field of an array UserType" do
    expect(subject.fields['receivers'].type.to_type_signature).to eq('[User!]!')
  end

  it "has a :team field of TeamType" do
    expect(subject.fields['team'].type.to_type_signature).to eq('Team!')
  end

  xit "has a :kudosMeter field of KudosMeterType" do
    expect(subject).to have_field(:kudosMeter).that_returns('KudosMeterType!')
  end

  xit "has a :votes field of VoteType" do
    expect(subject).to have_field(:votes).that_returns('[VoteType]!')
  end

  it "has a :created_at field of ISO8601DateTime type" do
    expect(subject.fields['createdAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end

  it "has a :updated_at field of ISO8601DateTime type" do
    expect(subject.fields['updatedAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end
end
