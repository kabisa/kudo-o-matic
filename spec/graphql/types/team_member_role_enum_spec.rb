# frozen_string_literal: true

RSpec.describe Types::TeamMemberRoleEnum do
  set_graphql_type

  it 'has a member value' do
    expect(subject.values['member'].value).to eq('member')
  end

  it 'has a moderator value' do
    expect(subject.values['moderator'].value).to eq('moderator')
  end

  it 'has an admin value' do
    expect(subject.values['admin'].value).to eq('admin')
  end
end