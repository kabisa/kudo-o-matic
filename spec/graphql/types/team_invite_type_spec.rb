# frozen_string_literal: true

RSpec.describe Types::TeamInviteType do
  set_graphql_type

  it "has an :id field of ID! type" do
    expect(subject.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it "has an :email field of EmailAddress! type" do
    expect(subject.fields['email'].type.to_type_signature).to eq('EmailAddress!')
  end

  it "has a :team field of TeamType! type" do
    expect(subject.fields['team'].type.to_type_signature).to eq('Team!')
  end

  it "has an :acceptedAt field of ISO8601DateTime type" do
    expect(subject.fields['acceptedAt'].type.to_type_signature).to eq('ISO8601DateTime')
  end

  it "has a :declinedAt field of ISO8601DateTime type" do
    expect(subject.fields['declinedAt'].type.to_type_signature).to eq('ISO8601DateTime')
  end

  it "has a :sentAt field of ISO8601DateTime type" do
    expect(subject.fields['sentAt'].type.to_type_signature).to eq('ISO8601DateTime')
  end
end
