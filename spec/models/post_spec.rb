# frozen_string_literal: true

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:users) { create_list(:user, 4) }
  let(:team) { create(:team) }

  before do
    team.add_member(user)
    users.each { |user| team.add_member(user) }
  end

  let(:kudos_meter) { team.active_kudos_meter }

  it "should have a valid factory" do
    expect(build(:post, sender: user, receivers: [users.second, users.third], team: team, kudos_meter: kudos_meter)).to be_valid
  end

  let(:post) { create(:post, sender: user, receivers: [users.second], team: team, kudos_meter: kudos_meter) }
  let!(:post_2) { create(:post, sender: user, receivers: [users.second, users.third], team: team, kudos_meter: kudos_meter) }
  let!(:post_3) { create(:post, sender: user, receivers: [users.second, users.third, users.fourth], team: team, kudos_meter: kudos_meter) }
  let!(:vote) { create(:vote, voter_id: user.id, votable_id: post.id) }

  it "can have one or more attached images" do
    post.images.attach(io: File.open("#{Rails.root}/spec/fixtures/images/rails.png"), filename: "rails.png", content_type: "image/png")
    expect(post.images.length).to be(1)

    post.images.attach(io: File.open("#{Rails.root}/spec/fixtures/images/rails.png"), filename: "rails.png", content_type: "image/png")
    expect(post.images.length).to be(2)

    expect(post.images).to be_attached
  end

  describe "model destroy dependencies" do
    it "should destroy dependent PostReceivers" do
      expect {post.destroy }.to change{ PostReceiver.count }
    end
  end

  describe "model validations" do
    it { is_expected.to validate_presence_of(:sender) }
    it { is_expected.to validate_presence_of(:receivers) }
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_length_of(:message) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount) }
    it { is_expected.to validate_presence_of(:team) }
    it { is_expected.to validate_presence_of(:kudos_meter) }
  end

  describe "model associations" do
    it { is_expected.to belong_to(:kudos_meter) }
    it { is_expected.to belong_to(:team) }
    it { is_expected.to belong_to(:activity) }
    it { is_expected.to belong_to(:sender) }
    it { is_expected.to have_many(:post_receivers).dependent(:destroy) }
    it { is_expected.to have_many(:receivers).through(:post_receivers) }
    it { is_expected.to have_many(:votes).with_foreign_key("votable_id") }
  end

  describe "validation #is_receiver_team_member?" do
    it 'should validate if all receivers are member of the team' do
      new_user = create(:user)
      expect do
        create(:post, sender: user, receivers: [new_user], team: team, kudos_meter: kudos_meter)
      end.to raise_error(ActiveRecord::RecordInvalid)

    end
  end

  describe 'custom validations' do

  end

  describe '#kudos_amount' do
    it 'returns the amount of kudos from posts and likes' do
      expect(post.kudos_amount).to eq(post.amount + post.votes.count)
    end
  end

  describe '#likes_amount' do
    it 'returns the amount of kudos from posts and likes' do
      expect(post.likes_amount).to eq(post.votes.count)
    end
  end

  describe '#receiver_name_feed' do
    it 'returns the names of the receivers' do
      # one receiver
      expect(post.receiver_name_feed).to eq(users.second.name)
      # two receivers
      expect(post_2.receiver_name_feed).to eq("#{users.second.name} and #{users.third.name}")
      # > 2 receivers
      expect(post_3.receiver_name_feed).to eq("#{users.second.name}, #{users.third.name}, #{users.fourth.name}")
    end
  end

  describe '#receiver_image' do
    it 'returns the avatars of the receivers' do
      # 1 receiver
      expect(post.receiver_image).to eq(users.second.picture_url)
      # > 1 receivers
      expect(post_2.receiver_image).to eq("#{users.second.picture_url}, #{users.third.picture_url}")
    end
  end
end
