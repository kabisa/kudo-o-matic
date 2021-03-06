RSpec.describe TeamInvite, type: :model do
  let!(:team) { create(:team) }
  let!(:team_invites) { create_list(:team_invite, 5, team: team) }

  it "should have a valid factory" do
    expect(build(:team_invite, team: team)).to be_valid
  end

  describe "model validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:team) }
  end

  describe "model associations" do
    it { is_expected.to belong_to(:team) }
  end

  describe "#complete?" do
    it "returns true if invite is accepted" do
      team_invites.first.accept
      expect(team_invites.first.complete?).to be true
    end

    it "returns true if invite is declined" do
      team_invites.first.decline
      expect(team_invites.first.complete?).to be true
    end

    it "returns false if invite is not accepted or declined" do
      expect(team_invites.first.complete?).to be false
    end
  end

  describe "#declined?" do
    it "returns true if invite is declined" do
      team_invites.first.decline
      expect(team_invites.first.declined?).to be true
    end

    it "returns false if invite is not declined" do
      expect(team_invites.first.declined?).to be false
    end
  end

  describe "#accept" do
    it "updates accepted_at" do
      expect { team_invites.first.accept }.to change { team_invites.first.accepted_at }.from(nil)
    end

    it "creates a team member" do
      expect { team_invites.first.accept }.to change { TeamMember.count }.by(1)
    end
  end

  describe "#decline" do
    it "updates declined_at" do
      expect { team_invites.first.decline }.to change { team_invites.first.declined_at }.from(nil)
    end
  end

  describe ".open" do
    it "returns the invites that are not accepted or declined" do
      expect(TeamInvite.open).to eq(team_invites)
    end
  end

  describe "#duplicate? & #send_invite" do
    it "sends an invite if invite is not a duplicate" do
      expect { create(:team_invite, team: team) }.to change {
        TeamInvite.count
        ActiveJob::Base.queue_adapter.enqueued_jobs.size
      }.by(1)
    end

    it "sends an invite if there is a duplicate invite that is declined" do
      create(:team_invite, :is_declined, email: 'email@example.com', team: team)

      expect { create(:team_invite, email: 'email@example.com', team: team) }.to change {
        TeamInvite.count
        ActiveJob::Base.queue_adapter.enqueued_jobs.size
      }.by(1)
    end

    it "raises an error and aborts the creation of a new invite if the invite is a duplicate" do
      create(:team_invite, email: 'email@example.com', team: team)

      expect { create(:team_invite, email: 'email@example.com', team: team) }.to raise_error(ActiveRecord::RecordNotSaved)
    end

    it "raises an error and aborts the creation of a new invite if the invite is a duplicate that is accepted" do
      create(:team_invite, :is_accepted, email: 'email@example.com', team: team)

      expect { create(:team_invite, email: 'email@example.com', team: team) }.to raise_error(ActiveRecord::RecordNotSaved)
    end
  end
end