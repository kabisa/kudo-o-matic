# frozen_string_literal: true

RSpec.describe Types::TeamType do
  set_graphql_type

  it "has an :id field of ID type" do
    expect(subject.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it "has a :name field of String! type" do
    expect(subject.fields['name'].type.to_type_signature).to eq('String!')
  end

  it "has a :slug field of String! type" do
    expect(subject.fields['slug'].type.to_type_signature).to eq('String!')
  end

  it "has a :users field of [UserType!]! type" do
    expect(subject.fields['users'].type.to_type_signature).to eq('[User!]!')
  end

  it "has a :posts field of an array [PostType!]! type" do
    expect(subject.fields['posts'].type.to_type_signature).to eq('PostsConnection!')
  end

  it "has a :kudosMeters field of an array KudosMeterType! type" do
    expect(subject.fields['kudosMeters'].type.to_type_signature).to eq('[KudosMeter!]!')
  end

  it "has a :activeKudosMeter field of KudosMeterType! type" do
    expect(subject.fields['activeKudosMeter'].type.to_type_signature).to eq('KudosMeter!')
  end

  it "has a :goals field of an array GoalType! type" do
    expect(subject.fields['goals'].type.to_type_signature).to eq('[Goal!]!')
  end

  it "has a :activeGoals field of an array GoalType! type" do
    expect(subject.fields['activeGoals'].type.to_type_signature).to eq('[Goal!]!')
  end

  it "has a :memberships field of an array TeamMemberType!" do
    expect(subject.fields['memberships'].type.to_type_signature).to eq('[TeamMember!]!')
  end

  it "has a :teamInvites field of an array TeamInviteType!" do
    expect(subject.fields['teamInvites'].type.to_type_signature).to eq('[TeamInvite!]!')
  end

  it "has a :guidelines field of an array GuidelineType! type" do
    expect(subject.fields['guidelines'].type.to_type_signature).to eq('[Guideline!]!')
  end

  it "has a :created_at field of ISO8601DateTime type" do
    expect(subject.fields['createdAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end

  it "has a :updated_at field of ISO8601DateTime type" do
    expect(subject.fields['updatedAt'].type.to_type_signature).to eq('ISO8601DateTime!')
  end
end
