# frozen_string_literal: true

RSpec.describe Goal, type: :model do
  let(:team) { create(:team) }
  let!(:kudos_meter) { team.active_kudos_meter }
  let!(:goals) { team.current_goals }
  let!(:goal) { goals.first }

  it "should have a valid factory" do
    expect(build(:goal)).to be_valid
  end

  describe "model validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:amount) }
  end

  describe "model associations" do
    it { is_expected.to belong_to(:kudos_meter) }
  end

  describe '.previous(team)' do
    it 'returns the previous goal of the team' do
      goal.achieve!

      expect(Goal.previous(team)).to eq(goal)
    end

    it 'returns nil if no record is found' do
      expect(Goal.previous(team)).to be_nil
    end
  end

  describe '.next(team)' do
    it 'returns the next goal of the team' do
      expect(Goal.next(team)).to eq(goals.first)
    end

    it 'returns nil if no record is found' do
      goals.all.map(&:achieve!)

      expect(Goal.next(team)).to be_nil
    end
  end

  describe '#achieved?' do
    it 'returns true if :achieved_on is present' do
      goal.achieve!
      expect(goal.achieved?).to be true
    end

    it 'returns false if :achieved_on is not present' do
      expect(goal.achieved?).to be false
    end
  end

  describe '#achieve!' do
    it 'marks goal as achieved' do
      expect { goal.achieve! }.to change { goal.achieved? }.from(false).to(true)
    end
  end
end
