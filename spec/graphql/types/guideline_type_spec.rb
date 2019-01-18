RSpec.describe Types::GuidelineType do
  set_graphql_type

  it "has an :id field of ID! type" do
    expect(subject.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it "has a :name field of String! type" do
    expect(subject.fields['name'].type.to_type_signature).to eq('String!')
  end

  it "has a :kudos field of Int! type" do
    expect(subject.fields['kudos'].type.to_type_signature).to eq('Int!')
  end

  it "has a :team field of TeamType! type" do
    expect(subject.fields['team'].type.to_type_signature).to eq('Team!')
  end
end