# frozen_string_literal: true

RSpec.describe Team, type: :model do
  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:new_kudos_meter) { create(:kudos_meter, team_id: team.id) }

  it "should have a valid factory" do
    expect(build(:team)).to be_valid
  end

  it "can have one attached logo" do
    team.logo.attach(io: File.open("#{Rails.root}/spec/fixtures/images/rails.png"), filename: "rails.png", content_type: "image/png")
    expect(team).to have_attached_file(:logo)
  end

  describe "model validations" do
    it { expect(team).to validate_presence_of(:name) }
    it {
      team.name = nil
      team.slug = nil
      expect(team).to_not be_valid
    }

    it "should validate content type of logo" do
      team.logo.attach(io: File.open("#{Rails.root}/spec/fixtures/files/dummy.txt"), filename: "dummy.txt", content_type: "text/plain")
      expect(team).to_not be_valid

      team.logo.attach(io: File.open("#{Rails.root}/spec/fixtures/images/rails.png"), filename: "rails.png", content_type: "image/png")
      expect(team).to be_valid
    end
  end

  describe "model associations" do
    it { is_expected.to have_many(:memberships).with_foreign_key("team_id") }
    it { is_expected.to have_many(:users).through(:memberships) }
    it { is_expected.to have_many(:kudos_meters) }
    it { is_expected.to have_many(:goals).through(:kudos_meters) }
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:guidelines) }
  end

  describe "active kudos meter" do
    it "has an active kudos meter" do
      expect(team.active_kudos_meter).to eq(kudos_meter)
    end

    it "sets the active kudos meter" do
      expect {
        team.active_kudos_meter = new_kudos_meter
      }.to change { team.active_kudos_meter}.from(kudos_meter).to(new_kudos_meter)
    end
  end

  describe "#slug_candidates" do
    it 'returns an array of name and name_and_sequence' do
      expect(team.slug_candidates).to eq([:name, :name_and_sequence])
    end
  end

  describe "#name_and_sequence" do
    it 'returns the team slug if slug is unique' do
      expect(team.slug).to eq(team.name.parameterize)
    end

    it 'returns the team slug with a sequence if slug is not unique' do
      team_2 = create(:team, name: team.name)

      expect(team_2.slug).to eq("#{team.slug}-2")
    end
  end

  let!(:user) { create(:user) }
  let!(:users) { create_list(:user, 3) }

  describe "#add_member(user, admin = false)" do
    it 'creates a new TeamMember' do
      team_member = team.add_member(user)

      expect(team_member).to eq(TeamMember.last)
      expect(team_member.role).to eq('member')
    end

    it 'creates a new TeamMember with admin rights' do
      team_member = team.add_member(user, 'admin')

      expect(team_member).to eq(TeamMember.last)
      expect(team_member.role).to eq('admin')
    end

    describe "#member?(user)" do
      it 'returns true if TeamMember' do
        team.add_member(user)

        expect(team.member?(user)).to be true
      end

      it 'returns false if not TeamMember' do
        expect(team.member?(user)).to be false
      end
    end

    describe "#membership_of(user)" do
      it 'returns the user if it has a membership' do
        member = team.add_member(user)

        expect(team.membership_of(user)).to eq(member)
      end

      it 'returns false if it has not a membership' do
        expect(team.membership_of(user)).to be_nil
      end
    end

    describe "#manageable_members(current_user)" do
      it 'returns all TeamMembers except the current and the company user' do
        user_2 = create(:user)

        member = team.add_member(user)
        member_2 = team.add_member(user_2)
        company_user = User.all.where(company_user: true)

        expect(team.manageable_members(user)).to_not include(member)
        expect(team.manageable_members(user)).to include(member_2)
        expect(team.manageable_members(user)).to_not include(company_user)
      end
    end

    describe "#current_goals" do
      it 'returns all goals from the active KudosMeter' do
        expect(team.current_goals).to eq(kudos_meter.goals)
      end
    end

    describe '#achieved_goals' do
      it 'returns the achieved goals of the team' do
        Goal.all.each(&:achieve!)
        expect(team.achieved_goals).to eq(kudos_meter.goals)
      end
    end

    describe "#real_users" do
      it 'returns all users that are not company users' do
        team.add_member(user)

        expect(team.real_users).to eq([user])
      end
    end
  end
end
