# frozen_string_literal: true

RSpec.describe Types::GoalType do
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

  it "has a :achievedOn field of Date type" do
    expect(subject.fields['achievedOn'].type.to_type_signature).to eq('Date')
  end

  it "has a :kudosMeter field of KudosMeterType! type" do
    expect(subject.fields['kudosMeter'].type.to_type_signature).to eq('KudosMeter!')
  end
end
