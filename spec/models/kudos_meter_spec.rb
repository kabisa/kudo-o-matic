# frozen_string_literal: true

RSpec.describe KudosMeter, type: :model do
  let(:kudos_meter) { create(:kudos_meter) }
  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let!(:post) { create(:post, sender: user, receivers: [user], kudos_meter: kudos_meter, team: team) }
  let!(:goal) { create(:goal, kudos_meter: kudos_meter) }

  it "should have a valid factory" do
    expect(build(:kudos_meter)).to be_valid
  end

  describe "model destroy dependencies" do
    it "should destroy dependent Posts" do
      expect { kudos_meter.destroy }.to change { Post.count }
    end

    it "should destroy dependent Goals" do
      expect { kudos_meter.destroy }.to change { Goal.count }
    end
  end

  describe "model validations" do
    # ensure that the name field is never empty
    it { expect(kudos_meter).to validate_presence_of(:name) }
  end

  describe "model associations" do
    # ensure that a kudos_meter belongs to team
    it { expect(kudos_meter).to belong_to(:team) }
    # ensure that a kudos_meter has many posts
    it { expect(kudos_meter).to have_many(:posts).dependent(:destroy) }
    # ensure that a kudos_meter has many goals
    it { expect(kudos_meter).to have_many(:goals).dependent(:destroy) }
  end
end
